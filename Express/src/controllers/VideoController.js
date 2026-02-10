import multer from 'multer';
import ffmpeg from 'ffmpeg-static';
import { spawn } from 'child_process';
import path from 'path';
import { publicPath } from '../../index.js';
import connect from '../../connectionDB.js';
import fs from 'fs/promises'; // Cambiado a fs/promises
import { existsSync } from 'fs'; // Para verificar existencia de archivos de forma síncrona

// Variable global para almacenar la conexión a la base de datos
let db = null;

// Función para iniciar la conexión a la base de datos
export async function initDb() {
    if (!db) {
        // si la conexión no existe la inicia aquí
        db = await connect();
        console.log("DB pool initialized");
    }
    return db;
}

// cntrolador para obtener todos los videos
export const getVideos = async (req, res) => {
    try {
        if (!db) {
            throw new Error("Database pool is null or undefined – connection never initialized?");
        }

        // busca en todos los videos de la base de datos
        const [rows] = await db.query('SELECT * FROM video');
        // da los resultados en formato JSON
        res.status(200).json(rows);
    } catch (err) {
        // control de errores en la consulta
        res.status(500).json({
            error: "Failed to fetch videos",
            details: err.message || "Unknown database error",
            code: err.code || "UNKNOWN"
        });
    }
};

// Controlador para obtener un vídeo por su ID
export const getVideoById = async (req, res) => {
    try {
        if (!db) {
            throw new Error("DB not initialized");
        }

        const { id } = req.params;
        const userId = req.user.user_id; // ID del usuario autenticado

        if (!id) {
            // Si no se envia ID devuelve error 400
            return res.status(400).json({ error: "Falta id del video" });
        }

        console.log(`Usuario ${userId} pide el vídeo ${id}`);

        // Consulta la URL del video en la base de datos
        const [rows] = await db.query(
            'SELECT url FROM video WHERE id = ?',
            [id]
        );

        if (rows.length === 0) {
            // Si no encuentra el video devuelve error 404
            return res.status(404).json({ error: "Video no encontrado" });
        }

        // Construye la ruta completa
        const playlistPath = path.join(process.cwd(), rows[0].url);

        if (!existsSync(playlistPath)) {
            // Si el archivo no existe en el sistema devuelve error 404
            return res.status(404).json({ error: "Archivo no encontrado" });
        }

        // Envia el archivo al cliente
        res.sendFile(playlistPath);
    } catch (err) {
        // Manejo de errores generales
        res.status(500).json({
            error: "Failed to fetch video",
            details: err.message
        });
    }
};

// Configuración de multer para subir archivos a memoria (sin guardar en disco)
const memoryUpload = multer({
    storage: multer.memoryStorage(), // Almacena el vídeo en memoria
    limits: { fileSize: 500 * 1024 * 1024 }, // Tamaño máximo 500MB
});

// Exporta el middleware de subida de vídeo
export const uploadVideo = memoryUpload;

// Controlador para procesar el vídeo subido
export const processVideo = async (req, res) => {
    const { clientId, videoId } = req;
    const WS = req.app.get('uploadScreenSocket');

    let tempVideoPath;
    let fixedVideoPath;

    try {
        WS.sendProgress(clientId, 70, 'Starting video processing...');

        if (!req.file || !req.file.buffer) {
            return res.status(400).json({ error: 'No se recibió ningún vídeo o está vacío' });
        }

        const outputDir = req.outputDir; // ya creado por middleware
        tempVideoPath = path.join(outputDir, 'temp_upload_video');
        fixedVideoPath = path.join(outputDir, 'fixed_video.mp4');
        const outputPlaylist = path.join(outputDir, 'index.m3u8');

        // Guardar vídeo temporal (usando fs/promises)
        await fs.writeFile(tempVideoPath, req.file.buffer);
        console.log('Temporary video saved:', tempVideoPath);

        // Crear versión "faststart" para evitar errores de MP4
        await new Promise((resolve, reject) => {
            const ffmpegFix = spawn('ffmpeg', ['-i', tempVideoPath, '-c', 'copy', '-movflags', '+faststart', fixedVideoPath]);
            ffmpegFix.stderr.on('data', d => console.log('FFmpeg fix:', d.toString()));
            ffmpegFix.on('close', code => code === 0 ? resolve() : reject(new Error('ffmpeg faststart failed')));
        });
        console.log('Fixed video created:', fixedVideoPath);

        // Argumentos para HLS
        const args = [
            '-i', fixedVideoPath, 
            '-profile:v', 'baseline',
            '-level', '3.0',
            '-start_number', '0',
            '-hls_time', '10',
            '-hls_list_size', '0',
            '-f', 'hls',
            outputPlaylist
        ];

        console.log('Executant FFmpeg:', args.join(' '));
        const ffmpegProcess = spawn(ffmpeg || 'ffmpeg', args);
        ffmpegProcess.stderr.on('data', d => console.log('FFmpeg HLS:', d.toString()));

        ffmpegProcess.on('close', async (code) => {
            try {
                if (code === 0) {
                    WS.sendProgress(clientId, 90, 'Cleaning up temporary files...');

                    // Eliminar archivos temporales después de procesar
                    try {
                        await fs.unlink(tempVideoPath);
                        console.log('Deleted temp video:', tempVideoPath);
                    } catch (err) {
                        console.warn('Could not delete temp video:', err.message);
                    }

                    try {
                        await fs.unlink(fixedVideoPath);
                        console.log('Deleted fixed video:', fixedVideoPath);
                    } catch (err) {
                        console.warn('Could not delete fixed video:', err.message);
                    }

                    WS.sendProgress(clientId, 100, 'Video processing completed');

                    req.processedVideoPath = `${videoId}/index.m3u8`;

                    WS.completeProcessing(clientId, {
                        videoId,
                        videoUrl: req.processedVideoPath,
                        thumbnailUrl: req.thumbnailPath,
                        metadata: {
                            duration: req.videoDuration,
                            codec: req.videoCodec,
                            resolution: req.videoResolution,
                            size: req.file.size
                        }
                    });

                    res.json({
                        success: true,
                        message: 'Video processed successfully',
                        data: {
                            videoId,
                            videoUrl: req.processedVideoPath,
                            thumbnailUrl: req.thumbnailPath
                        }
                    });
                } else {
                    console.error(`FFmpeg error code: ${code}`);
                    
                    // Intentar limpiar archivos temporales incluso si falla
                    await cleanupTempFiles(tempVideoPath, fixedVideoPath);
                    
                    res.status(500).json({ error: 'Error al procesar el video' });
                }
            } catch (cleanupError) {
                console.error('Error during cleanup:', cleanupError);
            }
        });

        ffmpegProcess.on('error', async (err) => {
            console.error('Error al iniciar FFmpeg:', err);
            
            // Intentar limpiar archivos temporales
            await cleanupTempFiles(tempVideoPath, fixedVideoPath);
            
            res.status(500).json({ error: 'Error al iniciar FFmpeg', details: err.message });
        });

        setTimeout(async () => {
            if (ffmpegProcess.pid && !ffmpegProcess.killed) {
                console.error('Timeout: killing FFmpeg');
                ffmpegProcess.kill('SIGKILL');
                
                // Limpiar archivos temporales por timeout
                await cleanupTempFiles(tempVideoPath, fixedVideoPath);
            }
        }, 600000); // 10 minutos

    } catch (error) {
        console.error('Video processing error:', error);
        
        // Intentar limpiar archivos temporales en caso de error
        await cleanupTempFiles(tempVideoPath, fixedVideoPath);
        
        WS.sendError(clientId, 'Video processing failed: ' + error.message);
        return res.status(500).json({ error: error.message });
    }
};

// Función auxiliar para limpiar archivos temporales
async function cleanupTempFiles(tempVideoPath, fixedVideoPath) {
    const filesToClean = [tempVideoPath, fixedVideoPath].filter(Boolean);
    
    for (const filePath of filesToClean) {
        try {
            if (existsSync(filePath)) {
                await fs.unlink(filePath);
                console.log('Cleaned up:', filePath);
            }
        } catch (err) {
            console.warn(`Could not delete ${filePath}:`, err.message);
        }
    }
}
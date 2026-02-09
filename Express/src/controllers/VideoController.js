import multer from 'multer';
import ffmpeg from 'ffmpeg-static';
import { spawn } from 'child_process';
import path from 'path';
import { publicPath } from '../../index.js';
import connect from '../../connectionDB.js';
import fs from 'fs';

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
            throw new Error("Database pool is null or undefined — connection never initialized?");
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

        if (!fs.existsSync(playlistPath)) {
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
export const processVideo = (req, res) => {
    const { clientId, videoId } = req;
    const WS = req.app.get('uploadScreenSocket'); // Socket para enviar progreso al cliente

    try {
        // Envía mensaje inicial 
        WS.sendProgress(clientId, 70, 'Starting video processing...');

        // Comprovar si se esta pujant un fitxer
        if (!req.file || !req.file.buffer) {
            return res.status(400).json({ error: 'No se recibió ningún vídeo o está vacío' });
        }

        const videoId = req.videoId;
        const outputPlaylist = path.join(req.outputDir, 'index.m3u8'); // Ruta de salida HLS

        // Argumentos para ffmpeg para convertir vídeo a HLS
        const args = [
            '-i', 'pipe:0', // Entrada desde stdin
            '-profile:v', 'baseline',
            '-level', '3.0',
            '-start_number', '0',
            '-hls_time', '10', // Duración de cada segmento HLS
            '-hls_list_size', '0', // Lista infinita
            '-f', 'hls', // Formato HLS
            outputPlaylist
        ];

        console.log('Executant FFmpeg:', ffmpeg, args.join(' '));

        // Inicia ffmpeg como proceso hijo
        const ffmpegProcess = spawn(ffmpeg || 'ffmpeg', args);

        // Muestra por consola los errores de ffmpeg
        ffmpegProcess.stderr.on('data', (data) => {
            console.log(`FFmpeg: ${data}`);
        });

        // Escribe el buffer del vídeo en ffmpeg
        setImmediate(() => {
            ffmpegProcess.stdin.write(req.file.buffer);
            ffmpegProcess.stdin.end();
        });

        // Cuando ffmpeg termina de procesar
        ffmpegProcess.on('close', (code) => {
            if (code === 0) {
                // Enviar progreso completo
                WS.sendProgress(clientId, 100, 'Video processing completed');

                // Guardar ruta procesada en la request
                req.processedVideoPath = `${videoId}/index.m3u8`;

                // Notificar que terminó
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

                // Enviar respuesta HTTP de correcto
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
                // Error en procesamiento
                console.error(`Error: ${code}`);
                res.status(500).json({ error: 'Error al processar el video' });
            }
        });

        // error al iniciar ffmpeg
        ffmpegProcess.on('error', (err) => {
            console.error('Error al iniciar FFmpeg:', err);
            res.status(500).json({ error: 'Error al iniciar FFmpeg', details: err.message });
        });

        // Timeout para FFmpeg
        setTimeout(() => {
            if (ffmpegProcess.pid && !ffmpegProcess.killed) {
                console.error('Timeout: kill FFmpeg per timeout');
                ffmpegProcess.kill('SIGKILL');
            }
        }, 600000); // 10 minutos de timeout

        // ffmpeg -i /home/disnaking/Downloads/videoplayback.mp4 -profile:v baseline -level 3.0 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls ./public/index.m3u8       
    } catch (error) {
        // falla cualquier cosa en el try y se notifica 
        WS.sendError(clientId, 'Video processing failed: ' + error.message);
        return res.status(500).json({ error: error.message });
    }
}

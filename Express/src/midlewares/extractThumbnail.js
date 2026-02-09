import { publicPath } from '../../index.js';
import fs from 'fs/promises';
import path from 'path';
import { spawn } from 'child_process';

// Middleware para generar miniatura de un video
export async function extractThumbnail(req, res, next) {
    const { clientId, videoId } = req;
    const WS = req.app.get('uploadScreenSocket');
    try {
        WS.sendProgress(clientId, 40, 'Starting thumbnail generation...');

        if (!req.file || !req.file.buffer) {
            return res.status(400).json({ error: 'No file uploaded or buffer missing' });
        }

        const videoId = req.videoId;
        if (!videoId) {
            throw new Error('videoId missing on request');
        }

        // crear directorio de salida para guardar thumbnail
        const outputDir = path.join(publicPath, videoId);
        await fs.mkdir(outputDir, { recursive: true });

        const thumbnailPath = path.join(outputDir, 'thumbnail.jpg');

        const file = req.file.buffer;
        const name = req.file.originalname || 'video';
        const type = req.file.mimetype || 'video/mp4';

        // Generar miniatura desde buffer del video
        const thumbnailBuffer = await generateThumbnailFromBuffer(file, name, type);

        WS.sendProgress(clientId, 70, 'Thumbnail generated successfully', {
            thumbnailUrl: `/public/${videoId}_thumbnail.png`
        });

        // Guardar miniatura 
        await fs.writeFile(thumbnailPath, thumbnailBuffer);

        req.outputDir = outputDir;

        next();
    } catch (error) {
        WS.sendError(clientId, 'Thumbnail generation failed: ' + error.message);
        return res.status(500).json({ error: error.message });
    }
}

// Genera un JPEG de miniatura a partir del buffer del vídeo
async function generateThumbnailFromBuffer(videoBuffer, originalName, mimeType) {
    return new Promise((resolve, reject) => {
        let inputFormat = 'mp4';
        const ext = path.extname(originalName || '').toLowerCase();
        if (ext === '.webm') inputFormat = 'webm';
        else if (ext === '.mov' || ext === '.qt') inputFormat = 'mov';
        else if (ext === '.avi') inputFormat = 'avi';
        if (mimeType.includes('webm')) inputFormat = 'webm';
        if (mimeType.includes('quicktime')) inputFormat = 'mov';

        const ffmpegArgs = [
            '-ss', '3', // seek inicial
            '-f', inputFormat,
            '-i', 'pipe:0',
            '-frames:v', '1',
            '-vf', 'scale=640:360:force_original_aspect_ratio=decrease,pad=640:360:(ow-iw)/2:(oh-ih)/2',
            '-q:v', '2',
            '-f', 'image2',
            '-vcodec', 'mjpeg',
            '-update', '1',
            'pipe:1'
        ];

        console.log('Running ffmpeg with args:', ffmpegArgs.join(' '));

        const ffmpegProcess = spawn('ffmpeg', ffmpegArgs);

        let thumbnailChunks = [];
        let stderrLines = [];

        // Captura salida de ffmpeg
        ffmpegProcess.stdout.on('data', (chunk) => {
            thumbnailChunks.push(chunk);
        });

        ffmpegProcess.stderr.on('data', (chunk) => {
            const line = chunk.toString().trim();
            if (line) stderrLines.push(line);
            console.log(`ffmpeg: ${line}`);
        });

        ffmpegProcess.on('error', (err) => {
            reject(new Error(`Failed to spawn ffmpeg: ${err.message}`));
        });

        ffmpegProcess.on('close', (code, signal) => {
            const stderr = stderrLines.join('\n');
            const thumbnail = Buffer.concat(thumbnailChunks);

            // Validacion de tamaño de thumbnail
            if (thumbnail.length >= 5000) {
                console.log(`Thumbnail success: ${thumbnail.length} bytes`);
                resolve(thumbnail);
            } else if (code === 0 && thumbnail.length > 0) {
                console.log(`Small thumbnail but code 0: ${thumbnail.length} bytes`);
                resolve(thumbnail);
            } else {
                reject(new Error(
                    `ffmpeg closed with code ${code || 'unknown'} (signal ${signal || 'none'})\n` +
                    `Thumbnail size: ${thumbnail.length} bytes\n` +
                    `Stderr:\n${stderr || '(no stderr)'}\n`
                ));
            }
        });

        ffmpegProcess.stdin.on('error', (err) => {
            if (err.code === 'EPIPE') {
                console.log('EPIPE on stdin ignored (ffmpeg finished reading early)');
            } else {
                console.error('Unexpected stdin error:', err);
                reject(err);
            }
        });

        // Enviar buffer a ffmpeg
        ffmpegProcess.stdin.write(videoBuffer);
        ffmpegProcess.stdin.end();
    });
}

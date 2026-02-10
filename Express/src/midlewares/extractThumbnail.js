import { publicPath } from '../../index.js';
import fs from 'fs/promises';
import path from 'path';
import { spawn } from 'child_process';

export async function extractThumbnail(req, res, next) {
    const { clientId } = req;
    const WS = req.app.get('uploadScreenSocket');

    try {
        WS.sendProgress(clientId, 40, 'Starting thumbnail generation...');

        if (!req.file || !req.file.buffer) return res.status(400).json({ error: 'No file uploaded or buffer missing' });

        const videoId = req.videoId;
        if (!videoId) throw new Error('videoId missing on request');

        const outputDir = path.join(publicPath, videoId);
        await fs.mkdir(outputDir, { recursive: true });

        const thumbnailPath = path.join(outputDir, 'thumbnail.jpg');
        const tempVideoPath = path.join(outputDir, 'temp_upload_video');
        const fixedVideoPath = path.join(outputDir, 'fixed_video.mp4');

        // Guardar vídeo temporal
        await fs.writeFile(tempVideoPath, req.file.buffer);

        // Reordenar MP4 amb faststart
        await new Promise((resolve, reject) => {
            const ffmpegFix = spawn('ffmpeg', ['-i', tempVideoPath, '-c', 'copy', '-movflags', '+faststart', fixedVideoPath]);
            ffmpegFix.stderr.on('data', d => console.log(d.toString()));
            ffmpegFix.on('close', code => (code === 0 ? resolve() : reject(new Error('ffmpeg faststart failed'))));
        });

        // Generar miniatura
        const thumbnailBuffer = await generateThumbnailFromFile(fixedVideoPath);

        await fs.writeFile(thumbnailPath, thumbnailBuffer);

        // Eliminar fitxers temporals
        await fs.unlink(tempVideoPath);
        await fs.unlink(fixedVideoPath);

        WS.sendProgress(clientId, 70, 'Thumbnail generated successfully', { thumbnailUrl: `/public/${videoId}/thumbnail.jpg` });

        req.outputDir = outputDir;
        req.thumbnailPath = `${videoId}/thumbnail.jpg`;
        next();

    } catch (error) {
        console.error('Thumbnail generation failed:', error.message);
        WS.sendError(clientId, 'Thumbnail generation failed: ' + error.message);
        return res.status(500).json({ error: error.message });
    }
}

async function generateThumbnailFromFile(videoPath) {
    return new Promise((resolve, reject) => {
        const ffmpegArgs = [
            '-ss','3','-i',videoPath,
            '-frames:v','1',
            '-vf','scale=640:360:force_original_aspect_ratio=decrease,pad=640:360:(ow-iw)/2:(oh-ih)/2',
            '-q:v','2','-f','image2','-vcodec','mjpeg','pipe:1'
        ];

        const ffmpegProcess = spawn('ffmpeg', ffmpegArgs);
        const chunks = [], stderr = [];

        ffmpegProcess.stdout.on('data', d => chunks.push(d));
        ffmpegProcess.stderr.on('data', d => stderr.push(d.toString()));

        ffmpegProcess.on('close', code => {
            const buffer = Buffer.concat(chunks);
            if (code === 0 && buffer.length > 5000) resolve(buffer);
            else reject(new Error(`FFmpeg thumbnail failed (code ${code})\n${stderr.join('')}`));
        });

        ffmpegProcess.on('error', reject);
    });
}

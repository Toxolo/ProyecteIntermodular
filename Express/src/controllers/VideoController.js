import multer from 'multer';
import ffmpeg from 'ffmpeg-static';
import { spawn } from 'child_process';
import path from 'path';
import fs from 'fs';
import { publicPath } from '../../index.js ';
import connect from '../../connectionDB.js';

let db = null;

export async function initDb() {
    if (!db) {
        db = await connect();
        console.log("DB pool initialized");
    }
    return db;
}

export const getVideos = async (req, res) => {
    try {
        if (!db) {
            throw new Error("Database pool is null or undefined — connection never initialized?");
        }

        const [rows] = await db.query('SELECT * FROM video');
        res.status(200).json(rows);
    } catch (err) {
            res.status(500).json({
            error: "Failed to fetch videos",
            details: err.message || "Unknown database error",
            code: err.code || "UNKNOWN"
        });
    }
};

const memoryUpload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 500 * 1024 * 1024 },
});

export const uploadVideo = memoryUpload;

export const processVideo = (req, res) => {

    /*
        Reproduir desde el front
        
        const formData = new FormData();
        formData.append('video', archivoVideo); 

        fetch('http://tu-servidor:3000/convert', {
            method: 'POST',
            body: formData
        })
            .then(res => res.json())
                .then(data => {
                    console.log('Vídeo listo en:', data.url);
                });

    */

    // Comprovar si s'esta pujant un fitxer
    if (!req.file || !req.file.buffer) {
        return res.status(400).json({ error: 'No se recibió ningún vídeo o está vacío' });
    }

    const videoId = req.videoId;
    const outputDir = publicPath + `/${videoId}`;
    const outputPlaylist = path.join(outputDir, 'index.m3u8');

    fs.mkdirSync(outputDir, { recursive: true });

    const args = [
        '-i', 'pipe:0',
        '-profile:v', 'baseline',
        '-level', '3.0',
        '-start_number', '0',
        '-hls_time', '10',
        '-hls_list_size', '0',
        '-f', 'hls',
        outputPlaylist
    ];

    console.log('Executant FFmpeg:', ffmpeg, args.join(' '));

    const ffmpegProcess = spawn(ffmpeg || 'ffmpeg', args);

    ffmpegProcess.stderr.on('data', (data) => {
        console.log(`FFmpeg: ${data}`);
    });

    setImmediate(() => {
        ffmpegProcess.stdin.write(req.file.buffer);
        ffmpegProcess.stdin.end();
    });

    ffmpegProcess.on('close', (code) => {
        if (code === 0) {

            const playlistUrl = `${req.protocol}://${req.get('host')}/public/${videoId}/index.m3u8`;
            res.json({ success: true, url: playlistUrl });
        } else {
            console.error(`Error: ${code}`);
            res.status(500).json({ error: 'Error al processar el video' });
        }
    });

    ffmpegProcess.on('error', (err) => {
        console.error('Error al iniciar FFmpeg:', err);
        res.status(500).json({ error: 'Error al iniciar FFmpeg', details: err.message });
    });


    setTimeout(() => {
        if (ffmpegProcess.pid && !ffmpegProcess.killed) {
            console.error('Timeout: kill FFmpeg per timeout');
            ffmpegProcess.kill('SIGKILL');
        }
    }, 60000);

    // ffmpeg -i /home/disnaking/Downloads/videoplayback.mp4 -profile:v baseline -level 3.0 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls ./public/index.m3u8       
};

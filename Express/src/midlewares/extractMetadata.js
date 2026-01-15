import { spawn } from 'child_process';

const FFPROBE = 'ffprobe'; // or static path if needed

export async function metadata(req, res, next) {
    if (!req.file || !req.file.buffer) {
        return res.status(400).json({
            error: 'No video file received. Send multipart/form-data with field "video".'
        });
    }

    console.log('File received → size:', req.file.size, 'bytes');

    // We run TWO quick probes (very fast) – one for duration, one for codec
    // You could combine them into one call, but separate is clearer/safer

    try {

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////

        const durationArgs = [
            '-v', 'error',
            '-show_entries', 'format=duration',
            '-of', 'default=noprint_wrappers=1:nokey=1',
            '-'
        ];

        const durationStr = await runFfprobe(req.file.buffer, durationArgs);
        const duration = Number(durationStr);

        if (isNaN(duration) || duration <= 0) {
            throw new Error(`Invalid duration: "${durationStr}"`);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////

        const codecArgs = [
            '-v', 'error',
            '-select_streams', 'v:0',
            '-show_entries', 'stream=codec_name',
            '-of', 'default=noprint_wrappers=1:nokey=1',
            '-'
        ];

        const codec = await runFfprobe(req.file.buffer, codecArgs);

        if (!codec || codec.trim() === '') {
            throw new Error('Could not detect video codec');
        }

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////

        const resolutionArgs = [
            '-v', 'error',
            '-select_streams', 'v:0',
            '-show_entries', 'stream=width,height',
            '-of', 'csv=p=0:s=x',
            '-'
        ];

        const resolution = await runFfprobe(req.file.buffer, resolutionArgs);

        if (!resolution || !resolution.includes('x')) {
            throw new Error('Could not detect video resolution');
        }

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //Metadates afegides al req per a ser accecibles desde les funcions posteriors

        req.videoId = Date.now().toString();
        req.videoDuration = duration;
        req.videoCodec = codec.trim();
        req.videoResolution = resolution.trim();
        // req.file.size -> size
        //req.file.originalname.split('.').slice(0,-1) -> name

        console.log(`Extracted: duration=${duration}s, codec=${req.videoCodec}, size = ${req.file.size}, name = ${req.file.originalname.split('.').slice(0, -1)}, resolution = ${req.videoResolution}`);

        next();

    } catch (err) {
        console.error('Metadata extraction failed:', err.message);
        return res.status(500).json({
            error: 'Failed to extract video metadata',
            details: err.message
        });
    }
}

async function runFfprobe(buffer, args) {
    return new Promise((resolve, reject) => {
        const child = spawn(FFPROBE, args, { encoding: 'utf8' });

        let output = '';
        let errorOutput = '';

        child.stdout.on('data', (data) => { output += data; });
        child.stderr.on('data', (data) => { errorOutput += data; });
        child.stdin.on('error', (err) => {
            if (err.code === 'EPIPE' || err.code === 'ECONNRESET') {
                return;
            }
            reject(err);
        });

        child.on('close', (code) => {
            if (code === 0) {
                resolve(output.trim());
            } else {
                reject(new Error(`ffprobe failed (code ${code}): ${errorOutput.trim() || 'no output'}`));
            }
        });

        child.on('error', reject);

        child.stdin.write(buffer);
        child.stdin.end();
    });
}
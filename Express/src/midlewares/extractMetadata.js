import { spawn } from 'child_process';
import { UploadScreenSocket } from '../websockets/uploadScreenSocket.js';

// Ruta o comando de ffprobe
const FFPROBE = 'ffprobe'; // or static path if needed

// Middleware para extraer metadatos de un video subido
export async function metadata(req, res, next) {
    // Obtener clientId desde headers
    const clientId = req.headers['x-client-id'];
    
    if (!clientId) {
        // error si no se envía clientId 
        return res.status(400).json({
            error: 'clientId is required in body or X-Client-Id header'
        });
    }

    // cosegir la instancia del WebSocket
    const WS = req.app.get('uploadScreenSocket');
    
    if (!WS || !WS.isClientConnected(clientId)) {
        // error si el cliente no esta conectado al WebSocket 
        return res.status(400).json({
            error: 'Client not connected to WebSocket'
        });
    }

    // Validar que se haya recibido un archivo de vídeo
    if (!req.file || !req.file.buffer) {
        return res.status(400).json({
            error: 'No video file received. Send multipart/form-data with field "video".'
        });
    }

    console.log('File received → size:', req.file.size, 'bytes');

    try {
        // Generar un ID único para el vídeo usando timestamp
        const videoId = Date.now().toString();
        
        WS.startProcessing(clientId, videoId, req.file.originalname);
        WS.sendProgress(clientId, 0, 'Starting metadata extraction...');

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Extract Duration (0% -> 7%)
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////

        WS.sendProgress(clientId, 2, 'Extracting video duration...');

        //  extraer la duración
        const durationArgs = [
            '-v', 'error', // solo errores
            '-show_entries', 'format=duration', // mostrar duración
            '-of', 'default=noprint_wrappers=1:nokey=1', // salida limpia
            '-' // entrada desde stdin
        ];

        // Ejecuta ffprobe y obtiene duración
        const durationStr = await runFfprobe(req.file.buffer, durationArgs);
        const duration = Number(durationStr);

        if (isNaN(duration) || duration <= 0) {
            // Si la duración no es válida, enviar error al cliente y lanzar excepción
            WS.sendError(clientId, `Invalid duration: "${durationStr}"`);
            throw new Error(`Invalid duration: "${durationStr}"`);
        }

        WS.sendProgress(clientId, 7, 'Duration extracted', { duration });

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Extract Codec (7% -> 14%)
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////

        WS.sendProgress(clientId, 8, 'Detecting video codec...');

        // extraer codec de vídeo
        const codecArgs = [
            '-v', 'error',
            '-select_streams', 'v:0', // seleccionar stream de vídeo
            '-show_entries', 'stream=codec_name', // mostrar codec
            '-of', 'default=noprint_wrappers=1:nokey=1',
            '-'
        ];

        const codec = await runFfprobe(req.file.buffer, codecArgs);

        if (!codec || codec.trim() === '') {
            // error si no detecta codec y excepción
            WS.sendError(clientId, 'Could not detect video codec');
            throw new Error('Could not detect video codec');
        }

        WS.sendProgress(clientId, 14, 'Codec detected', { codec: codec.trim() });

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Extract Resolution (14% -> 20%)
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////

        WS.sendProgress(clientId, 15, 'Detecting video resolution...');

        // extraer resolución
        const resolutionArgs = [
            '-v', 'error',
            '-select_streams', 'v:0',
            '-show_entries', 'stream=width,height', // ancho y alto
            '-of', 'csv=p=0:s=x', // salida en formato WxH
            '-'
        ];

        const resolution = await runFfprobe(req.file.buffer, resolutionArgs);

        if (!resolution || !resolution.includes('x')) {
            // error sii no se detecta resolución válida y excepción
            WS.sendError(clientId, 'Could not detect video resolution');
            throw new Error('Could not detect video resolution');
        }

        WS.sendProgress(clientId, 20, 'Metadata extraction completed', {
            duration,
            codec: codec.trim(),
            resolution: resolution.trim(),
            size: req.file.size,
            filename: req.file.originalname
        });

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Attach metadata to request for next middleware
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////

        req.clientId = clientId;
        req.videoId = videoId;
        req.videoDuration = duration;
        req.videoCodec = codec.trim();
        req.videoResolution = resolution.trim();
        req.videoName = req.file.originalname.split('.').slice(0, -1).join('.');
        // req.file.size = tamaño en bytes
        // req.file.originalname = nombre original del archivo

        // Enviar mensaje con metadata por WebSocket
        WS.sendMessage(clientId, {
            clientId: clientId,
            type: 'metadata',
            videoId: videoId,
            duration: duration,
            codec: req.videoCodec,
            resolution: req.videoResolution,
            size: req.file.size,
            filename: req.videoName
        });

        console.log(`Extracted: duration=${duration}s, codec=${req.videoCodec}, size=${req.file.size}, name=${req.videoName}, resolution=${req.videoResolution}`);

        // siguiente middleware
        next();

    } catch (err) {
        //control de errores
        console.error('Metadata extraction failed:', err.message);
        WS.sendError(clientId, 'Metadata extraction failed: ' + err.message);
        return res.status(500).json({
            error: 'Failed to extract video metadata',
            details: err.message
        });
    }
}

// obtener salida
async function runFfprobe(buffer, args) {
    return new Promise((resolve, reject) => {
        const child = spawn(FFPROBE, args, { encoding: 'utf8' });

        let output = '';
        let errorOutput = '';

        // Captura stdout de ffprobe
        child.stdout.on('data', (data) => { output += data; });
        // Captura stderr de ffprobe
        child.stderr.on('data', (data) => { errorOutput += data; });
        // control de errores de stdin
        child.stdin.on('error', (err) => {
            if (err.code === 'EPIPE' || err.code === 'ECONNRESET') {
                return; // ignorar errores de pipe
            }
            reject(err);
        });

        //  ffprobe finaliza
        child.on('close', (code) => {
            if (code === 0) {
                resolve(output.trim()); // devolver salida
            } else {
                reject(new Error(`ffprobe failed (code ${code}): ${errorOutput.trim() || 'no output'}`));
            }
        });

        // control de error general del proceso
        child.on('error', reject);

        // Escribir buffer de video a ffprobe y cerrar stdin
        child.stdin.write(buffer);
        child.stdin.end();
    });
}

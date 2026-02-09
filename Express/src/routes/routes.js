import express from 'express';
import {processVideo,uploadVideo,getVideos, getVideoById } from '../controllers/VideoController.js';
import {metadata} from '../midlewares/extractMetadata.js';
import { extractThumbnail } from '../midlewares/extractThumbnail.js';
import verifyToken from '../midlewares/verifyToken.js';

const Routes = express.Router();

Routes.post('/vid',uploadVideo.single('video'), metadata, extractThumbnail, processVideo); //para poder subir videos
Routes.get('/', getVideos); //enviar todos los videos
Routes.get('/video/:id', verifyToken, getVideoById); //dar la direccion protegida del video siempre que pase el verifytoken

export default Routes;


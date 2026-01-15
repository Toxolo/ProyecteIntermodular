import express from 'express';
import {processVideo,uploadVideo,getVideos} from '../controllers/VideoController.js';
import {metadata} from '../midlewares/extractMetadata.js';

const Routes = express.Router();

Routes.post('/vid',uploadVideo.single('video'),metadata, processVideo);
Routes.get('/', getVideos);

export default Routes;


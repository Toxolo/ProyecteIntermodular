import express from 'express';
import {processVideo,uploadVideo,getVideos} from '../controllers/VideoController.js';
import {metadata} from '../midlewares/extractMetadata.js';
import { saveDB } from '../midlewares/saveMetadataDB.js';

const Routes = express.Router();

Routes.post('/vid',uploadVideo.single('video'), metadata, saveDB, processVideo);
Routes.get('/', getVideos);
Routes.post('/meta', uploadVideo.single('video'), metadata);

export default Routes;


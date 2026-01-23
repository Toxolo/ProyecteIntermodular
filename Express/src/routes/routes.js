import express from 'express';
import {processVideo,uploadVideo,getVideos} from '../controllers/VideoController.js';
import {metadata} from '../midlewares/extractMetadata.js';
import { saveDB } from '../midlewares/saveMetadataDB.js';
import { extractThumbnail } from '../midlewares/extractThumbnail.js';

const Routes = express.Router();

Routes.post('/vid',uploadVideo.single('video'), metadata, saveDB, extractThumbnail, processVideo);
Routes.get('/', getVideos);

export default Routes;


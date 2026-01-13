import express from 'express';
import {processVideo,uploadVideo,get} from '../controllers/VideoController.js';
import {metadata} from '../midlewares/extractMetadata.js';

const Routes = express.Router();

Routes.post('/vid',uploadVideo.single('video'),metadata, processVideo);
Routes.get('/', get);

export default Routes;


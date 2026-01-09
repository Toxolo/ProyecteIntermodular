import express from 'express';
import {processVideo,uploadVideo,get} from '../controllers/VideoController.js';

const Routes = express.Router();

Routes.post('/vid',uploadVideo.single('video'), processVideo);
Routes.get('/', get);

export default Routes;


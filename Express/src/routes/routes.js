import router from 'express';

const VideoRouter = Router => {
    const Routes = router.Router();

    Routes.post('/vid',videoController.uploadVideo)
}
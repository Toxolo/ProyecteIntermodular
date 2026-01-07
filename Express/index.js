import express from 'express';
const app = express();
const port = 3000;
import Router from './src/routes/routes.js';

app.use(express.json());
app.use(Router);


app.listen(port, ()=> {
    console.log(`Server is running on http://localhost:${port}`);
});
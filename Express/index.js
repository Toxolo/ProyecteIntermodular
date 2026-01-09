import express from 'express';
const app = express();
const port = 3000;
import Routes from './src/routes/routes.js';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


app.use(express.json());

export const publicPath = path.join(__dirname, 'public');
console.log(publicPath);

export const publicFolder = express.static('public');
app.use(publicFolder);


app.use(Routes);

app.listen(port, ()=> {
    console.log(`Server is running on http://localhost:${port}`);
});
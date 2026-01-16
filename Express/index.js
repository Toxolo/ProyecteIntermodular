import express from 'express';

const app = express();
const port = 3000;

import cors from 'cors';

app.use(cors({
  origin: [
    'http://localhost:1420',
    'http://localhost:5173'
  ],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false,
}));

import Routes from './src/routes/routes.js';
import path from 'path';
import { fileURLToPath } from 'url';
import {initDb} from './src/controllers/VideoController.js'

await initDb();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


app.use(express.json());

app.use(express.static('public'))


export const publicPath = path.join(__dirname, 'public');
console.log(publicPath);

app.use('/static', express.static('public'));


app.use(Routes);

app.listen(port, ()=> {
    console.log(`Server is running on http://localhost:${port}`);
});
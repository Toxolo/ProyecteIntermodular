import express from 'express';

const app = express();
const port = 3000;

import cors from 'cors';

app.use(cors({
  origin: [
    'http://localhost:1420'
  ],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization','X-Client-Id'],
  credentials: false,
}));


// WebSocket setup
import http from "http";
import {UploadScreenSocket} from "./src/websockets/uploadScreenSocket.js";
const server = http.createServer(app);
const uploadScreenSocket = new UploadScreenSocket();
uploadScreenSocket.initialize(server);
app.set('uploadScreenSocket', uploadScreenSocket);


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



app.use(Routes);

server.listen(port, '0.0.0.0', () => {
  console.log(`Listening on http://localhost:${port}`);
});
import express from 'express';
import https from 'https';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = 3000;
const httpsOptions = { // Carga certificados para tener HTTPS
  key: fs.readFileSync(path.join(__dirname, 'keys', 'private.key')),
  cert: fs.readFileSync(path.join(__dirname, 'keys', 'certificate.crt')),
};


import cors from 'cors';

app.use(cors({
  origin: [
    'https://localhost:1420'
  ],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization','X-Client-Id'],
  credentials: false,
}));


// WebSocket setup
import {UploadScreenSocket} from "./src/websockets/uploadScreenSocket.js";
const server = https.createServer(httpsOptions, app); // Creamos servidor HTTPS
const uploadScreenSocket = new UploadScreenSocket();
uploadScreenSocket.initialize(server);
app.set('uploadScreenSocket', uploadScreenSocket);


import Routes from './src/routes/routes.js';
import {initDb} from './src/controllers/VideoController.js'

await initDb();


app.use(express.json());

app.use('/static', express.static(path.join(__dirname, 'public')));


export const publicPath = path.join(__dirname, 'public');
console.log(publicPath);



app.use(Routes);

server.listen(port, '0.0.0.0', () => {
  console.log(`Listening on https://localhost:${port}`);
});
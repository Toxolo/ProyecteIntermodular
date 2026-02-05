import jwt from 'jsonwebtoken';
import fs from 'fs';
import path from 'path';

// Ruta ABSOLUTA a la clave pública
const publicKey = fs.readFileSync(
  path.resolve('keys/public.pem'),
  'utf8'
);

export default function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  console.log("funciona")

  if (!authHeader) {
    return res.status(401).json({ message: 'Token no proporcionado' });
  }

  const token = authHeader.split(' ')[1];

  jwt.verify(
    token,
    publicKey,
    { algorithms: ['RS256'] },
    (err, decoded) => {
        if (err) {
        return res.status(403).json({ message: 'Token inválido' });
    }

      // para usarlo en el controlador de la peticion de video.
    req.user = decoded;

      next();
    }
  );
}

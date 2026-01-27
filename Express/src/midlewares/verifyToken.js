export function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];

    // No hay token
    if (!authHeader) {
        return res.status(403).json({
            error: 'No hay tocken'
        });
    }

    const [type, token] = authHeader.split(' ');

    if (type !== 'Bearer' || !token) {
        return res.status(403).json({
            error: 'Formato de token incorrecto'
        });
    }

    // Comprobar que es un JWT
    const parts = token.split('.');
    if (parts.length !== 3) {
        return res.status(401).json({
            error: 'Token inválido'
        });
    }

    // Decodificar SOLO payload (sin verificar firma)
    try {
        const payload = JSON.parse(
            Buffer.from(parts[1], 'base64').toString()
        );

        // Comprobar expiración si existe
        if (payload.exp && Date.now() / 1000 > payload.exp) {
            return res.status(401).json({
                error: 'Token expirado'
            });
        }

        req.user = payload;
        next();
    } catch (err) {
        return res.status(401).json({
            error: 'Token inválido'
        });
    }
}

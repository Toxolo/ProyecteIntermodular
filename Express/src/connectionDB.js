import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

async function connect() {
    try {
        const pool = mysql.createPool({
            host: process.env.MYSQL_HOST || 'localhost',
            port: process.env.MYSQL_PORT || '3306',
            user: process.env.DB_USER || 'user',
            password: process.env.DB_PASSWORD || 'password',
            database: process.env.MYSQL_DATABASE || 'users',
            waitForConnections: true,
            connectionLimit: 10,
            queueLimit: 0,
        });
        console.log('Conexión a MySQL establecida.');
        return pool;
    } catch (error) {
        console.error('Error al conectar a MySQL:', error);
        throw error;
    }
}

export default connect;
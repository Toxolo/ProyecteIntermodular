import connect from "../../connectionDB.js";

const db = await connect();

export const saveDB = async(req,res,next) => {

    const size = Math.round(req.file.size /1024)

    const result = db.query(
        'INSERT INTO video (id, titol, duracio, codec, resolucio, pes) VALUES(?, ?, ?, ?, ?, ?)',
        [req.videoId, req.file.originalname.split('.').slice(0,-1), req.videoDuration, req.videoCodec, req.videoResolution, size]
    )
    console.log(result);
    next();
}
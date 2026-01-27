USE CatalegSpring;

-- =========================
-- ESTUDI
-- =========================
INSERT INTO estudi (name) VALUES ('Estudi PixelArts');
INSERT INTO estudi (name) VALUES ('DreamFrame Studios');
INSERT INTO estudi (name) VALUES ('CineMax Productions');

-- =========================
-- SERIE
-- =========================
INSERT INTO serie (name, classification) VALUES ('Sèrie Fantàstica', 1);
INSERT INTO serie (name, classification) VALUES ('Aventura Espacial', 2);
INSERT INTO serie (name, classification) VALUES ('Comedia Urbana', 1);

-- =========================
-- CATEGORIA
-- =========================
INSERT INTO categoria (name) VALUES ('Acció');
INSERT INTO categoria (name) VALUES ('Aventura');
INSERT INTO categoria (name) VALUES ('Comedia');
INSERT INTO categoria (name) VALUES ('Drama');
INSERT INTO categoria (name) VALUES ('Ciència Ficció');
INSERT INTO categoria (name) VALUES ('Animació');

-- =========================
-- VIDEO_CATALEG
-- =========================
INSERT INTO video_cataleg
(title, description, chapter, duration, rating, season, thumbnail, serie_id, estudi_id)
VALUES
('La Gran Aventura', 'Una expedició èpica travessant mars i muntanyes plenes de misteri.', 1, 130, 4.8, 1, 'gran_aventura.jpg', 1, 1),
('Risc al Cosmos', 'Exploració espacial amb perills increïbles i encontres inesperats.', 1, 145, 4.5, 1, 'risc_cosmos.jpg', 2, 2),
('Comèdia a la Ciutat', 'Situacions hilarants i personatges extravagants que et faran riure.', 1, 90, 4.2, 1, 'comedia_ciutat.jpg', 3, 3),
('Misteri a la Foscor', 'Un drama intens on el destí dels personatges està en joc.', 2, 120, 4.9, 1, 'misteri_foscor.jpg', 1, 1),
('Viure entre Estrelles', 'Ciència ficció amb descobriments tecnològics i conflictes intergalàctics.', 2, 150, 4.7, 1, 'viure_estrelles.jpg', 2, 2),
('Animació Màgica', 'Personatges animats en aventures fantàstiques plenes de colors.', 2, 100, 4.6, 1, 'animacio_magica.jpg', 3, 3),
('Lluita Final', 'Acció sense parar amb batalles èpiques.', 3, 140, 4.8, 2, 'lluita_final.jpg', 1, 1),
('Missió Impossible', 'Aventura perillosa amb girs inesperats.', 3, 155, 4.9, 2, 'missio_impossible.jpg', 2, 2),
('Rialles Sense Fi', 'Comèdia plena de situacions absurdes.', 3, 95, 4.4, 2, 'rialles_sense_fi.jpg', 3, 3);

-- =========================
-- VIDEO_CATEGORIA
-- =========================
INSERT INTO video_categoria VALUES (1,1),(1,2),(4,1),(4,2),(7,1),(7,2);
INSERT INTO video_categoria VALUES (2,2),(2,5),(5,2),(5,5),(8,2),(8,5);
INSERT INTO video_categoria VALUES (3,3),(3,6),(6,3),(6,6),(9,3),(9,6);
INSERT INTO video_categoria VALUES (4,4);

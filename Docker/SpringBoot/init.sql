CREATE DATABASE IF NOT EXISTS `CatalegSpring`;
USE `CatalegSpring`;
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.1.2-MariaDB, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: CatalegSpring
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `categoria_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`categoria_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `categoria` VALUES
(1,'Acció'),
(2,'Aventura'),
(3,'Comedia'),
(4,'Drama'),
(5,'Ciència Ficció'),
(6,'Animació');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
commit;

--
-- Table structure for table `estudi`
--

DROP TABLE IF EXISTS `estudi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `estudi` (
  `estudi_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`estudi_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estudi`
--

/*!40000 ALTER TABLE `estudi` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `estudi` VALUES
(1,'Estudi PixelArts'),
(2,'DreamFrame Studios'),
(3,'CineMax Productions');
/*!40000 ALTER TABLE `estudi` ENABLE KEYS */;
commit;

--
-- Table structure for table `historial`
--

DROP TABLE IF EXISTS `historial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `historial` (
  `id_historial` bigint NOT NULL AUTO_INCREMENT,
  `completed` bit(1) NOT NULL,
  `latest_play` int NOT NULL,
  `visualization` int NOT NULL,
  `perfil_id` bigint NOT NULL,
  `usuari_id` bigint NOT NULL,
  `video_id` bigint NOT NULL,
  `completat` bit(1) NOT NULL,
  PRIMARY KEY (`id_historial`),
  UNIQUE KEY `UK6gabu0tuaekqsdlqnqesow91n` (`perfil_id`,`video_id`),
  KEY `FK2iw8u5nex9le9hqvtf1mvx3hj` (`usuari_id`),
  KEY `FK22mc6wi2bl0mudoopdo2bi1m5` (`video_id`),
  CONSTRAINT `FK22mc6wi2bl0mudoopdo2bi1m5` FOREIGN KEY (`video_id`) REFERENCES `video_cataleg` (`id_video_cataleg`),
  CONSTRAINT `FK2iw8u5nex9le9hqvtf1mvx3hj` FOREIGN KEY (`usuari_id`) REFERENCES `usuari` (`user_id`),
  CONSTRAINT `FKrtjrpb1botgo9v96615jc4omf` FOREIGN KEY (`perfil_id`) REFERENCES `perfil` (`perfil_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historial`
--

/*!40000 ALTER TABLE `historial` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `historial` ENABLE KEYS */;
commit;

--
-- Table structure for table `perfil`
--

DROP TABLE IF EXISTS `perfil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfil` (
  `perfil_id` bigint NOT NULL AUTO_INCREMENT,
  `infantile` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `user` bigint NOT NULL,
  PRIMARY KEY (`perfil_id`),
  KEY `FK9c19wj6ce6uf1y5vadlok269j` (`user`),
  CONSTRAINT `FK9c19wj6ce6uf1y5vadlok269j` FOREIGN KEY (`user`) REFERENCES `usuari` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfil`
--

/*!40000 ALTER TABLE `perfil` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `perfil` ENABLE KEYS */;
commit;

--
-- Table structure for table `serie`
--

DROP TABLE IF EXISTS `serie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `serie` (
  `serie_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `classification` int NOT NULL,
  PRIMARY KEY (`serie_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `serie`
--

/*!40000 ALTER TABLE `serie` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `serie` (serie_id, name) VALUES
(1,'Sèrie Fantàstica'),
(2,'Aventura Espacial'),
(3,'Comedia Urbana');

/*!40000 ALTER TABLE `serie` ENABLE KEYS */;
commit;

--
-- Table structure for table `usuari`
--

DROP TABLE IF EXISTS `usuari`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuari` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuari`
--

/*!40000 ALTER TABLE `usuari` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `usuari` ENABLE KEYS */;
commit;

--
-- Table structure for table `valoracio_video`
--

DROP TABLE IF EXISTS `valoracio_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `valoracio_video` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rating` int NOT NULL,
  `perfil_id` bigint NOT NULL,
  `video_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKa2pou5jg1ysv7k5bhmf0i98qi` (`perfil_id`),
  KEY `FK6yih2qcv30buyfxiony5mvcnw` (`video_id`),
  CONSTRAINT `FK6yih2qcv30buyfxiony5mvcnw` FOREIGN KEY (`video_id`) REFERENCES `video_cataleg` (`id_video_cataleg`),
  CONSTRAINT `FKa2pou5jg1ysv7k5bhmf0i98qi` FOREIGN KEY (`perfil_id`) REFERENCES `perfil` (`perfil_id`),
  CONSTRAINT `valoracio_video_chk_1` CHECK (((`rating` <= 5) and (`rating` >= 1)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `valoracio_video`
--

/*!40000 ALTER TABLE `valoracio_video` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `valoracio_video` ENABLE KEYS */;
commit;

--
-- Table structure for table `video_cataleg`
--

DROP TABLE IF EXISTS `video_cataleg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `video_cataleg` (
  `id_video_cataleg` bigint NOT NULL AUTO_INCREMENT,
  `chapter` int NOT NULL,
  `date_emission` date NOT NULL DEFAULT (curdate()),
  `description` varchar(255) NOT NULL,
  `duration` int NOT NULL,
  `rating` double DEFAULT NULL,
  `season` int DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `serie_id` bigint DEFAULT NULL,
  `estudi_id` bigint NOT NULL,
  PRIMARY KEY (`id_video_cataleg`),
  KEY `FKdjr5qesl7c5qtdw8b2quaswgq` (`serie_id`),
  KEY `FKs8aab5cfd0e5gpjnlq13gveji` (`estudi_id`),
  CONSTRAINT `FKdjr5qesl7c5qtdw8b2quaswgq` FOREIGN KEY (`serie_id`) REFERENCES `serie` (`serie_id`),
  CONSTRAINT `FKs8aab5cfd0e5gpjnlq13gveji` FOREIGN KEY (`estudi_id`) REFERENCES `estudi` (`estudi_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_cataleg`
--

/*!40000 ALTER TABLE `video_cataleg` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `video_cataleg` VALUES
(1,1,3,'Situacions hilarants i personatges extravagants que et faran riure.',90,4.2,1,'comedia_ciutat.jpg','Comèdia a la Ciutat',3,3),
(2,1,3,'Situacions hilarants i personatges extravagants que et faran riure.',90,4.2,1,'comedia_ciutat.jpg','Comèdia a la Ciutat',3,3),
(3,1,3,'Situacions hilarants i personatges extravagants que et faran riure.',90,4.2,1,'comedia_ciutat.jpg','Comèdia a la Ciutat',3,3),
(4,2,1,'Un drama intens on el destí dels personatges està en joc.',120,4.9,1,'misteri_foscor.jpg','Misteri a la Foscor',1,1),
(5,2,2,'Ciència ficció amb descobriments tecnològics i conflictes intergalàctics.',150,4.7,1,'viure_estrelles.jpg','Viure entre Estrelles',2,2),
(6,2,3,'Personatges animats en aventures fantàstiques plenes de colors i fantasia.',100,4.6,1,'animacio_magica.jpg','Animació Màgica',3,3),
(7,3,1,'Acció sense parar amb batalles èpiques i estratègies sorprenents.',140,4.8,2,'lluita_final.jpg','Lluita Final',1,1),
(8,3,2,'Una aventura perillosa amb girs inesperats i intriga contínua.',155,4.9,2,'missio_impossible.jpg','Missió Impossible',2,2),
(9,3,3,'Comèdia plena de situacions absurdes que no deixaran de sorprendre.',95,4.4,2,'rialles_sense_fi.jpg','Rialles Sense Fi',3,3);
/*!40000 ALTER TABLE `video_cataleg` ENABLE KEYS */;

commit;

--
-- Table structure for table `video_categoria`
--

DROP TABLE IF EXISTS `video_categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `video_categoria` (
  `id_video_cataleg` bigint NOT NULL,
  `categoria_id` bigint NOT NULL,
  PRIMARY KEY (`id_video_cataleg`,`categoria_id`),
  KEY `FK7ybn87c6tqc0eu7uj5697swp5` (`categoria_id`),
  CONSTRAINT `FK7ybn87c6tqc0eu7uj5697swp5` FOREIGN KEY (`categoria_id`) REFERENCES `categoria` (`categoria_id`),
  CONSTRAINT `FKax9debk56yxtatwbdiilq8qex` FOREIGN KEY (`id_video_cataleg`) REFERENCES `video_cataleg` (`id_video_cataleg`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_categoria`
--

/*!40000 ALTER TABLE `video_categoria` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `video_categoria` VALUES
(4,1),
(7,1),
(4,2),
(5,2),
(7,2),
(8,2),
(3,3),
(6,3),
(9,3),
(4,4),
(5,5),
(8,5),
(3,6),
(6,6),
(9,6);
/*!40000 ALTER TABLE `video_categoria` ENABLE KEYS */;
commit;

--
-- Dumping routines for database 'CatalegSpring'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-01-15 11:42:35
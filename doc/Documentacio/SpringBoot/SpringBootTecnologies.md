# Tecnologies del Backend

Este document descriu breument les principals tecnologies utilitzades en el backend del projecte, així com el seu paper dins de l’arquitectura general de l’aplicació.

---

## Spring Boot

Spring Boot és el framework principal del backend. Permet crear aplicacions Java de manera ràpida i estructurada, reduint molt la configuració inicial.

En este projecte, Spring Boot s’encarrega de:

* Arrancar l’aplicació i gestionar el cicle de vida del backend.
* Exposar l’API REST mitjançant controllers.
* Gestionar la injecció de dependències entre les diferents capes.
* Integrar-se de forma senzilla amb Hibernate, JPA i Spring Security.

Gràcies a Spring Boot, el backend queda modular, escalable i fàcil de mantindre.

---

## CORS (Cross-Origin Resource Sharing)

El backend té configurat **CORS** per permetre la comunicació entre els frontends (Vue, flutter) i el backend (Spring Boot), encara que estiguen en dominis o ports diferents.

La configuració CORS permet:

* Acceptar peticions des del frontend.
* Controlar quins mètodes HTTP estan permesos (GET, POST, PUT, DELETE).
* Definir si s’accepten credencials com ara tokens JWT.


---

## Hibernate

Hibernate és el framework ORM (Object Relational Mapping) utilitzat per a mapar les classes Java amb les taules de la base de dades.

En el projecte:

* Cada entitat del domini correspon a una taula de la base de dades.
* Hibernate s’encarrega de generar o validar l’estructura de les taules en arrancar l’aplicació.
* Traduïx automàticament les operacions Java en consultes SQL.


---

## JPA (Java Persistence API)

JPA és l’especificació estàndard que definix com s’ha de gestionar la persistència de dades en Java. Hibernate és la implementació utilitzada en este projecte. 

L’ús de JPA aporta:

* Independència del motor de base de dades.
* Anotacions clares per definir entitats, relacions i claus primàries.
* Una capa d’abstracció que facilita el manteniment del codi.

---

##  Repositoris JPA

Els **repositoris JPA** s’utilitzen per accedir a la base de dades de forma neta i desacoblada. (https://docs.spring.io/spring-data/jpa/docs/current/api/org/springframework/data/jpa/repository/JpaRepository.html)

En el projecte:

* Es definixen interfícies Repository en la capa de domini.
* Spring genera automàticament les implementacions bàsiques (CRUD).
* Les implementacions concretes s’integren amb Hibernate i la base de dades.

Açò permet separar clarament la lògica de negoci de l’accés a dades, seguint els principis de Clean Architecture.

---

##  Resum

El backend combina Spring Boot, Hibernate i JPA per oferir una API REST robusta, segura i escalable. Esta combinació permet:

* Separació clara de responsabilitats.
* Facilitat per mantindre i ampliar el projecte.
* Integració senzilla amb el frontend mitjançant CORS i endpoints REST.

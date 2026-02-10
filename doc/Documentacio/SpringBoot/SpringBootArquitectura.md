# Arquitectura Clean al Spring boot

---

## 1. Què és l'Arquitectura Clean?

L'Arquitectura Clean és una manera d'organitzar el codi perquè:

* El **domini** siga independent de frameworks
* Les **regles de negoci** no depenguen de la base de dades ni de Spring
* El codi siga **fàcil de mantindre, provar i escalar**

Es basa en capes concèntriques, on les dependències **sempre apunten cap a dins**.

Emb decidit utilitzar aquesta arquitectura perque vam pensar que seria la milllor i més comoda per a treballar en grup sense tindre una caos d'arxius, o arxius de 500 linies son molt complexos de modificar per a un company que entra desde 0 al backend de spring

---

## 2. Visió general de les capes

Tenim estes capes principals:

```
Presentation → Application → Domain ← Infrastructure
```

* Presentation: entrada i eixida de dades (API REST, DTOs)
* Application: casos d'ús (use cases)
* Domain: nucli del sistema (entitats i regles)
* Infrastructure: implementacions tècniques (JPA, repositoris, controllers)

A més tenim la capa security, aquesta capa la hem decidit crear per a introduir el cors i el control del token d'oodo. Ja que considerabem que aixi era la forma més neta d'implementaro i facil d'ampliar a futur 

---

## 3. Capa Domain (Nucli del sistema)

`org.padalustro.domain`

### 3.1 Entities

`domain/entities`

Conté les **entitats del negoci** :

* `video_cataleg`  aquesta es la tabla principal del projecte, a on es guarden les dade i metadades del videos
* `categoria` aquesta tabla son les categories que te cada video
* `serie` aquesta tabla són les series, que servixen per agrupar els videos per llistes
* `estudi` aquesta tabla són els estudis que aporten el videos

---------------------------------------------

Les seguents tables són creades per a implementacións a futur a l'aplicació, al tindreles ja creades amb la bd adapta, ens sera molt més sencill implementar les seguents millores

* `usuari`  aquesta tabla fara referencia a l'usuari d'odoo 
* `perfil` aquesta tabla servira per a gestionar els diversos perfils que pot tindre un usuari, si són menors d'edad, etc.
* `historial` aquesta tabla la vam preparar per a tindre un historial dels ids del videos vists per un perfil, i cuan van ser vists.
* valoracio_video aquesta tabla va ser preparada per a un servei de valoracións a on el perfils podien donar la seva opinio sobre un video, i puntuarlo

### 3.2 Repositories (Ports)

`domain/repository`

Asi tenim els repositoris:

* `VideoCatalegRepository`
* `EstudiRepository`
* `SerieRepository`
* `CategoriaRepository`

Són **interfícies**, no implementacions.

### 3.3 Exceptions

`domain/exceptions`

Aço son control de errors per saber que esta pasan cuan ens dona un error:

* `VideoCatalegNotFoundException`

      Aquesta classe s'utilitza quan es vol accedir o eliminarun VideoCataleg que NO existeix en la base de dades.
*  GlobalExceptionHandler

    Aquest mètode s'executa automaticament quan

   es llança una VideoCatalegNotFoundException

   en qualsevol punt del projecte.

---

## 4. Capa Application (Casos d'ús)

`org.padalustro.application.usecase`

Ací està la **lògica d'aplicació**, organitzada per agregats:

### Exemple: Video Catàleg

 `usecase/Cataleg`

* `GetAllVideoCatalegUseCase`
* `GetVideoCatalegByIdUseCase`
* `SaveVideoCatalegUseCase`
* `UpdateVideoCatalegUseCase`
* `DeleteVideoCatalegUseCase`

Cada Use Case:

* Fa **una única acció**
* Depén només de **repositoris del domini**
* No coneix controllers ni JPA

 Exemple conceptual:

```
Controller → UseCase → Repository (interface)
```

El mateix patró es repetix en:

* `Category`
* `Serie`
* `Estudi`

---

## 5. Capa Infrastructure (Detalls tècnics)

`org.padalustro.infrastructure`

Esta capa implementa els detalls concrets.

### 5.1 Repository Implementations

`infrastructure/repository`

* `VideoCatalegRepositoryImpl`
* `CategoriaRepositoryImpl`
* `SerieRepositoryImpl`

Implementen les interfícies del domini utilitzant JPA. Asi el teniu si li voleu donar una mira ([https://docs.spring.io/spring-data/jpa/docs/current/api/org/springframework/data/jpa/repository/JpaRepository.html](https://docs.spring.io/spring-data/jpa/docs/current/api/org/springframework/data/jpa/repository/JpaRepository.html))

### 5.2 JPA Repositories

`infrastructure/repository/jpa`

* `VideoCatalegJpaRepository`
* `CategoriaJpaRepository`

Són repositoris Spring Data (`JpaRepository`).

Només s'usen dins de la infraestructura.

---

## 6. Capa Presentation

`org.padalustro.presentation`

### 6.1 Controllers

`infrastructure/controller`

* `VideoCatalegController`
* `CategoryController`
* `SerieController`
* `StudiController`

Funcions:

* Rebre peticions HTTP
* Validar dades
* Cridar els Use Cases
* Retornar respostes HTTP

### 6.2 DTOs

`presentation/DTO`

* `VideoCatalegDTO`
* `CategoriaDTO`
* `SerieDTO`
* `EstudiDTO`

Servixen per:

* No exposar entitats del domini
* Controlar què entra i què ix de l'API

---

## 7. Seguretat

`org.padalustro.security`

* `SecurityConfig`
* `CorsConfig`

És una capa transversal que afecta Presentation i Infrastructure, però **no toca Domain ni Application**.

---

## 8. Punt d'entrada de l'aplicació

* `CatalegBackend.java`
* `Index.java`

Arranquen Spring Boot i configuren el context.

---

## 9. Flux complet d'una petició

Exemple: obtenir un vídeo pel seu ID

```
HTTP Request
   ↓
VideoCatalegController
   ↓
GetVideoCatalegByIdUseCase
   ↓
VideoCatalegRepository (interface)
   ↓
VideoCatalegRepositoryImpl
   ↓
JPA Repository
   ↓
Base de dades
```

---

## 10. Conclusió

Arquitectura Clean:

* Domini net i independent
* Casos d'ús clars
* Infraestructura desacoblada
* API REST ben separada


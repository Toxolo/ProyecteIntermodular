# Documentació API REST – Endpoints


##  Autenticació i autorització

* Tots el endpoints requerixen **usuari autenticat**, aunque no siga necesaria la subscripció.
* Els endpoints marcats com a **ADMIN** requerixen que el token JWT continga el camp:

```
"is_admin": true
```

## CategoryController

**Base path:** `/Category`

### GET /Category

* **Descripció:** Dona el json de totes les categories
* **Auth:** No requerida
* **Resposta:** `200 OK` – Llista de categories

### GET /Category/{id}

* **Descripció:** Dona el json d’una categoria pel seu id
* **Path param:** `id` (Long)
* **Auth:** No requerida
* **Resposta:** `200 OK` – Categoria

### POST /Category

* **Descripció:** Crea una categoria nova
* **Auth:** ADMIN
* **Body:** `CategoriaDTO`
* **Resposta:** `201 Created`

### POST /Category/varios

* **Descripció:** Crea diverses categories. Este endpoint s’utilitza principalment per a proves de desenvolupament
* **Auth:** ADMIN
* **Body:** `List<CategoriaDTO>`
* **Resposta:** `201 Created`

### PUT /Category/{id}

* **Descripció:** Modifiquem una categoria pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Body:** `CategoriaDTO`
* **Resposta:** `200 OK | 404 Not Found`

### DELETE /Category/{id}

* **Descripció:** Eliminem una categoria pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Resposta:** `204 No Content | 404 Not Found`

## SerieController

**Base path:** `/Serie`

### GET /Serie

* **Descripció:** Dona el json de totes les sèries
* **Auth:** No requerida
* **Resposta:** `200 OK` – Llista de sèries

### GET /Serie/{id}

* **Descripció:** Dona el json d’una sèrie pel seu id
* **Path param:** `id`
* **Auth:** No requerida
* **Resposta:** `200 OK` – Sèrie

### POST /Serie

* **Descripció:** Crea una sèrie nova
* **Auth:** ADMIN
* **Body:** `SerieDTO`
* **Resposta:** `201 Created`

### POST /Serie/varios

* **Descripció:** Crea diverses sèries. Este endpoint s’utilitza principalment per a proves de desenvolupament
* **Auth:** ADMIN
* **Body:** `List<SerieDTO>`
* **Resposta:** `201 Created`

### PUT /Serie/{id}

* **Descripció:** Modifiquem una sèrie pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Body:** `SerieDTO`
* **Resposta:** `200 OK | 404 Not Found`

### DELETE /Serie/{id}

* **Descripció:** Eliminem una sèrie pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Resposta:** `204 No Content | 404 Not Found`

## EstudiController

**Base path:** `/Estudi`

### GET /Estudi

* **Descripció:** Dona el json de tots els estudis
* **Auth:** No requerida
* **Resposta:** `200 OK` – Llista d'estudis

### GET /Estudi/{id}

* **Descripció:** Dona el json d’un estudi pel seu id
* **Path param:** `id`
* **Auth:** No requerida
* **Resposta:** `200 OK` – Estudi

### POST /Estudi

* **Descripció:** Crea un estudi nou
* **Auth:** ADMIN
* **Body:** `EstudiDTO`
* **Resposta:** `201 Created`

### POST /Estudi/varios

* **Descripció:** Crea diversos estudis. Este endpoint s’utilitza principalment per a proves de desenvolupament
* **Auth:** ADMIN
* **Body:** `List<EstudiDTO>`
* **Resposta:** `201 Created`

### PUT /Estudi/{id}

* **Descripció:** Modifiquem un estudi pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Body:** `EstudiDTO`
* **Resposta:** `200 OK | 404 Not Found`

### DELETE /Estudi/{id}

* **Descripció:** Eliminem un estudi pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Resposta:** `204 No Content | 404 Not Found`

## VideoCatalegController

**Base path:** `/Cataleg`

### GET /Cataleg/

* **Descripció:** Endpoint de prova que retorna un missatge de benvinguda
* **Auth:** No requerida
* **Resposta:** `200 OK` – Missatge de benvinguda

### GET /Cataleg

* **Descripció:** Dona el json de tots els vídeos del catàleg
* **Auth:** Usuari autenticat
* **Resposta:** `200 OK` – Llista de vídeos

### GET /Cataleg/{id}

* **Descripció:** Dona el json d’un vídeo del catàleg pel seu id
* **Path param:** `id`
* **Auth:** No requerida
* **Resposta:** `200 OK` – Vídeo

### POST /Cataleg

* **Descripció:** Crea un vídeo nou dins del catàleg
* **Auth:** ADMIN
* **Body:** `VideoCatalegDTO`
* **Resposta:** `201 Created`

### PUT /Cataleg/{id}

* **Descripció:** Modifiquem un vídeo del catàleg pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Body:** `VideoCatalegDTO`
* **Resposta:** `200 OK | 404 Not Found`

### DELETE /Cataleg/{id}

* **Descripció:** Eliminem un vídeo del catàleg pel seu id
* **Auth:** ADMIN
* **Path param:** `id`
* **Resposta:** `204 No Content | 404 Not Found`


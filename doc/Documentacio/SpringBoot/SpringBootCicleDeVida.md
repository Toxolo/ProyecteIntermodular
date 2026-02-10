#  Cicle de vida del backend (API REST)

Este document descriu **pas a pas** què ocorre al backend des que s’encén l’aplicació fins que gestiona una petició HTTP i torna a quedar-se a l’espera de la següent.

---

## 1 Arrancada de l’aplicació

Quan s’executa l’aplicació (per exemple amb `SpringBootApplication.run()`):

* El **contenidor de Spring** s’inicialitza.
* Es carreguen les **configuracions** (`application.yml` / `application.properties`).
* Spring detecta i registra tots els **beans** (`@Controller`, `@Service`, `@Repository`, etc.).

---

## 2 Connexió amb la base de dades

Durant l’arrancada:

* Spring crea el **DataSource** amb les dades de connexió (URL, usuari, password).
* Hibernate intenta **connectar-se a la base de dades**.
* Si la connexió falla → l’aplicació **no arranca**.

---

## 3 Validació de taules amb Hibernate

Hibernate comprova l’estat de la base de dades segons la propietat:

```properties
spring.jpa.hibernate.ddl-auto
```

Valors habituals:

* `validate` → comprova que les taules existixen i coincidixen amb les entitats.
* `update` → crea o modifica taules si cal.
* `create` / `create-drop` → recrea l’esquema complet.

 Si hi ha errors d’estructura (camps que no coincidixen), **l’aplicació no arranca**.

---

## 4 Backend llest i en espera

Una vegada:

* La BD està connectada
* Les entitats són vàlides
* Els beans estan carregats

El backend queda **a l’espera de peticions HTTP**.

El servidor queda escoltant en un port:

```
http://localhost:8090
```

---

## 5 Arribada d’una petició HTTP

Quan arriba una petició (per exemple `GET /Category`):

1. El servidor rep la petició.
2. Spring identifica el **controller** corresponent segons:

   * Ruta (`@RequestMapping`, `@GetMapping`, etc.)
   * Mètode HTTP (GET, POST, PUT, DELETE)

---

## 6 Filtres i seguretat (JWT)

Abans d’entrar al controller:

* Passa pels **filtres de seguretat**.
* Si l’endpoint requerix autenticació:

  * Es valida el **token JWT**.
  * Es comproven rols (USER / ADMIN).

Si falla la seguretat → resposta `401` o `403`.

---

## 7 Controller (Capa d’entrada)

El controller:

* Rep la petició HTTP.
* Valida dades bàsiques (path, body, params).
* **No conté lògica de negoci**.
* Crida al **Use Case / Service** corresponent.

El controller només fa de pont entre HTTP i l’aplicació.

---

## 8 Use Case / Service (Lògica de negoci)

En esta capa:

* S’executa la **lògica real** de l’aplicació.
* Es crida als repositoris si cal accedir a dades.

Exemples:

* Validar que una categoria no existix.
* Comprovar permisos.
* Preparar dades de resposta.

---

## 9 Repository (Accés a dades)

Els repositoris:

* Executen consultes a la BD mitjançant Hibernate.
* Retornen entitats o DTOs.

Hibernate:

* Traduïx les operacions Java a **SQL**.
* Executa les consultes.
* Mapeja els resultats a objectes.

---

## 10 Tornada de la resposta

Una vegada:

* El service retorna el resultat al controller.
* El controller genera la resposta HTTP:

  * Codi (`200`, `201`, `204`, `404`, etc.)
  * Cos JSON si cal.

Spring serialitza automàticament els objectes a **JSON**.

---

## 11 Finalització de la petició

* La resposta s’envia al client.
* La connexió HTTP es tanca.
* No es manté estat entre peticions (API REST).

El backend torna a quedar-se **a l’espera d’una nova petició**.

---

## Resum visual del flux

```
Arrancada
  ↓
Configuració
  ↓
Connexió BD
  ↓
Validació Hibernate
  ↓
Espera peticions
  ↓
Petició HTTP
  ↓
Filtres / Seguretat
  ↓
Controller
  ↓
Service / Use Case
  ↓
Repository / BD
  ↓
Resposta HTTP
  ↓
Espera de nou
```

---
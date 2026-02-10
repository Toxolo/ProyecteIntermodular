# Arquitectura Frontend – Vue

Este document descriu l’arquitectura utilitzada al frontend del projecte, basada en la configuració per defecte de Vue 3 i organitzada per funcionalitats (feature-based) amb capes clares de presentació, components, serveis i utilitats.

---

## Entry Point

**`main.ts` i `App.vue`**

* Inicialitzen l’aplicació Vue.
* Munten el component principal `App.vue`.
* Configuren el router i plugins necessaris.


---

## Routing i Seguretat

**`router/index.ts` i `router/routeguard.ts`**

* Gestionen les rutes de l’aplicació.
* Protegeixen rutes segons rol o autenticació.
* Faciliten navegació i redireccions.


---

## Components per Funcionalitat (Feature-based)

**`components/`**

* Cada carpeta correspon a una funcionalitat del negoci: Categories, Estudis, Series, Videos.
* Contenen components reutilitzables i independents per a cada feature.
* Separació clara: Card, List.


* EditScreen, esta asi, perque no estan acabats als 100% ja que la idea es un pantalla de editar, que cride al component de edit i al de borrar un video, pero de moment esta asi perque el backend de express no elimina videos fins la proxima versio del projecte


---

## Screens / Views

**`screens/`**

* Components de nivell alt que representen pantalles completes.
* Connecten **components** amb **serveis**.
* Coincideixen amb rutes definides.


---

## Serveis (Service Layer)

**`services/`**

* Centralitzen la comunicació amb el backend.
* Gestionen tokens, autenticació i crides HTTP.
* Eviten que els components accedeixin directament a la API.

Exemples: `api.ts`, `authFetch.ts`, `token.ts`.

---

## Utilitats compartides

**`utils/`**

* Conté funcions reutilitzables com `auth.ts`.
* No depenen de Vue ni de cap component.
* Faciliten manteniment i reutilització de codi.

* Estem plantejant l'idea de fucionar utils i services perque el que tenim es casi el mateix. I no nem a partir la estructura de forma innecesaria

---

## Assets

**`assets/css/`**

* Estils CSS separats per component i funcionalitat.
* Facilita la coherència visual i el manteniment.


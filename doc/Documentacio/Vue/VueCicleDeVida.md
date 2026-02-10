# Vue Frontend – Cicle de vida i connexió WebSocket

Aquest document descriu com funciona un component Vue amb `<script setup>` en el projecte, des del muntatge fins a la gestió d’una petició al backend amb WebSocket.

---

## 1. Cicle de vida del component

### Creació del component
- Vue inicialitza totes les **refs** i objectes reactius declarats amb `ref()` o `reactive()`.
- Es configuren valors inicials per a formularis, dropdowns i variables de control (`file`, `previewUrl`, `progressBar`, `error`, etc.).

### Carregant dades inicials
- Al muntar el component (`onMounted()`), es crida `loadReferenceData()`.
- Aquesta funció fa **peticions HTTP** via `api` (axios amb token automàtic) per obtenir:
  - Categories (`/Category`)
  - Estudis (`/Estudi`)
  - Sèries (`/Serie`)
- Els resultats es guarden en `categories`, `estudios` i `series`.
- Mentrestant, les variables `loadingCategories`, `loadingEstudios` i `loadingSeries` indiquen l’estat de càrrega.

### Esperant interacció de l’usuari
- El component espera que l’usuari seleccioni un fitxer, ompli el formulari o seleccioni categories, estudi i sèrie.

### Gestió d’esdeveniments
- `handleFileChange(e)` valida el fitxer seleccionat i genera un **preview**.
- Errors de validació es mostren a `error.value`.

### Cicle de submissió
- Quan l’usuari fa clic a **Guardar**, es crida `handleSave()`.
- Aquesta funció invoca `uploadVideoAndSave()`, que realitza:
  1. **Upload del fitxer** al servei de vídeo (`POST http://localhost:3000/vid`).
  2. **Preparació del payload** amb les dades exactes que espera el backend.
  3. **POST al backend principal** (`/Cataleg`) amb les dades del vídeo.
  4. **Actualització de la UI** amb barra de progrés i missatges via WebSocket.

### Reset del formulari
- Un cop finalitzat l’upload i guardat el registre, es crida `resetForm()` per tornar a l’estat inicial i esperar la següent acció de l’usuari.

---

## 2. Connexió amb WebSocket

### Inicialització
- Al muntar el component, es crida `connectWebSocket()`.
- Es crea un objecte **WebSocket** amb la URL del servei (`ws://localhost:3000/vid`).

### Gestió d’esdeveniments
- `onopen`: es connecta correctament el client.
- `onmessage`: rep missatges JSON del servidor. Tipus de missatges:
  - **connection**: assigna un `clientId` únic.
  - **progress**: actualitza la barra de progrés si el `clientId` coincideix.
  - **metadata**: completa dades del vídeo (duració, codec, resolució, pes) a `form.value`.
- `onclose`: indica que la connexió s’ha tancat.

### Avantatges
- Mostra **progressos d’upload en temps real**.
- Manté el component reactiu sense necessitat de polling.
- El WebSocket es manté actiu mentre el component existeix.

---

## 3. Flux resumit del component

```
Component Vue monta
│
├─> Inicialitza refs i form
│
├─> onMounted()
│ ├─> loadReferenceData() → Backend GET categories/estudis/series
│ └─> connectWebSocket() → WS connect
│
Esperant acció de l'usuari
│
Usuari selecciona fitxer i omple formulari
│
handleFileChange() valida fitxer i mostra preview
│
Usuari fa clic en Guardar
│
uploadVideoAndSave()
├─> POST vídeo a servei de vídeo
├─> POST payload al backend
└─> WS progress actualitzat en temps real
│
resetForm() → torna a l’estat inicial
│
Esperant nova acció
```
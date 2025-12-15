# Diagrama ER Conceptual

```uml

@startuml
left to right direction

entity Usuari {
  *id: Integer <<PK>>
  --
  nom: String
  cognom: String
  email: String
  password: String
  adreca: String
  edat: Integer
}

entity Admin {
  *id: Integer <<PK>>
  --
  nom: String
  password: String
}

entity Suscripcio {
  *id: Integer <<PK>>
  --
  tipus: String
  inici: Date
  fi: Date
}

entity Perfil {
  *id: Integer <<PK>>
  --
  nom: String
  infantil: Boolean
}

entity Serie {
  *id: Integer <<PK>>
  --
  nom: String
}

entity Video_Cataleg {
  *id: Integer <<PK>>
  --
  titol: String
  duracio: Integer
  categoria: String
  descripcio: String
  thumbnail_url: String
  classificacio_edat: Integer
  estudi: String
  valoracio: Double
  temporada: Integer
  episodi: Integer
  data_estrena: Date
}

entity Video {
  *id: Integer <<PK>>
  --
  url_fragments: String
  format: String
}

entity Visualitzacio {
  *perfil_id: Integer <<FK>>
  *video_cataleg_id: Integer <<FK>>
  --
  temps_vist: Integer
  ultima_reproduccio: Date
  completat: Boolean
  valoracio_usuari: Integer
}

' Relaciones
Usuari ||--o{ Perfil : "crea"
Usuari }o--o{ Suscripcio : "contrata"
Admin }o--o{ Suscripcio : "gestiona"
Admin ||--o{ Video : "puja"
Admin ||--o{ Video_Cataleg : "administra"

Video ||--|| Video_Cataleg : "pertany a"

Serie ||--o{ Video_Cataleg : "conté"

Perfil }o--o{ Visualitzacio : "registra"
Video_Cataleg }o--o{ Visualitzacio : "té"

@enduml
```
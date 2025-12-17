# Diagrama Modelo Datos

```uml
@startuml

entity Usuari {
    *id : Integer <<PK>>
    ---
    Nom: varchar(50)
    Cognom: varchar(50)
    rol: ENUM ('Admin' , 'Usuario')
    email: varchar(100)
    password: varchar(50)
    direccio: varchar(100)
    fechaNacimiento: date
    suscripcio: integer <<FK>>
    metodoPago: integer <<FK>>
    iniciSuscripcio: Date
    fiSuscripcio: Date
}

entity Suscripcio {
    *id : integer <<PK>>
    ---
    tipo: ENUM('Premium','Familiar'...)
    preu: double
    duracio: date
}

Usuari ||--o{ Suscripcio

entity MetodoPago {
    *id: integer <<PK>>
    ---

}




@enduml
```

@startuml
left to right direction

actor Usuari

rectangle "Server" {
  usecase "Comprobar credencials" as RV
  usecase "Llistar videos" as IS
  usecase "Trobar .mp4" as EC
  usecase "Validar suscripció" as CF
}

Usuari --> IS
Usuari --> EC
Usuari --> CF
Usuari --> RV


@enduml


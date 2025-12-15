@startuml

left to right direction

actor Usuari

rectangle "Server" {
  usecase "ruta" as ruta
  usecase "post .mp4" as post
  usecase "EDITAR METADATA" as editar
  usecase "get catalog" as catalog
  usecase "Delete .mp4\nAND\ncataleg" as delete
  usecase "UPDATE\nVID CAT" as update
  usecase "COMPROBAR\nERROR" as error
}

Usuari --> ruta
Usuari --> post
Usuari --> editar
Usuari --> catalog
Usuari --> delete
Usuari --> update
Usuari --> error

@enduml




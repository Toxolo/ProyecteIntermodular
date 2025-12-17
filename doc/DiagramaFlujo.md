# Diagrama de flujo

```uml
@startuml

(*) --> Obrir_app

if "Te conter ?" then

    -left->[true] Token

    if "" then

        -->[true] "Sel_Perfil"
        --> Cataleg
        --> Buscar
        --> Info_Video

        if "Reproducir ?" then
            if "Suscrito ?" then
                if "Reproduccion" then
                    -right->[true] Reproducir_Video
                    -->[fin video] Info_Video
                else
                    -> Cataleg
                endif
            else
                -up->[false] payment
            endif
        else
            -->[false] "Insertar en lista"
            -right-> Buscar_Lista
        endif
            
        Buscar --> Buscar_Lista
        --> Info_Video
        Buscar --> Crear
        Buscar --> Borrar
    else
        -right->[false] "Iniciar_Sessio"
        -down-> Sel_Perfil
        Iniciar_Sessio --> Config
        --> Perfiles
        --> Crear_Perfil
        Perfiles --> Eliminar_Perfil
        Perfiles --> Modificar_Perfil
        Config --> "Modificar Pagament"
        Config --> "Tancar Sessio"
    endif

else

    -right->[false] "crear_conter"

    if "suscribirse" then
        -right->[true] payment
        --> Iniciar_Sessio
    else
        -left->[false] Iniciar_Sessio
    endif

endif

@enduml
```

@startuml
start
:Abre APP;

if (¿Tiene cuenta?) then (NO)

  :Crear Cuenta
  (Work);

  if(Pagar) then (SI)
    :Suscribirse;
  else (NO)
  endif
else (SI)
endif

if (¿Tiene token?) then (NO)
  :Iniciar Sesión;
else (SI)
endif

:Sel. Perfil;

if (¿Ver cataleg?) then (SÍ)
  :Buscar Contenido;
  
  if (¿Ver Info MP?) then (SÍ)
    if (¿Repro directa?) then (SÍ)
        if (¿Estas suscrito?) then (Sí)
            :Repro .mp4;
        else (NO)
            if(Pagar) then (SI)
                :Suscribirse;
            else (NO)
  endif   
        endif
    else (NO)
      if (+ lista) then (SI)
      :Añadir lista;
    else (NO)
    endif
    endif
  else (NO)
    :Buscar Lista;
    split
      :Crear Lista;
    split again
      :Borrar;
    end split
  endif
  
else (NO)
  :Config;
  split
    :Perfiles;
    split
      :Crear;
    split again
      :Borrar;
    split again
      :Mod;
    end split
  split again
    :Pagamento (odoo);
  split again
    :Cerrar Sesión;
  end split
endif

stop
@enduml
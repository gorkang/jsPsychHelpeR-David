# CONTROL + Alt + R para correr archivo

# Install packages ---------------------------------------------------------

  # Descomentar y correr la primera vez (o cuando hay errores)
  # source("setup.R")


# Sync data from server ---------------------------------------------------

 # FORM, protocol 5. [This is sentitive data]
  # Status FORM, protocol 6. [This is sentitive data]
  # Protocol 1


# Destroy cache (_targets folder) -----------------------------------------
  
  # Destruye cache para forzar que se gatille la preparacion de datos
  targets::tar_destroy()
  
  
# Run project --------------------------------------------------------------
  
  targets::tar_make()

  
# Visualize targets networks -----------------------------------------------
  
  # Para ver el arbol de dependencias
  # targets::tar_visnetwork(targets_only = TRUE, label = "time") #label = "time"

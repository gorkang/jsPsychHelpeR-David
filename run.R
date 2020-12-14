
# Install packages ---------------------------------------------------------

  source("setup.R")


# Sync data from server ---------------------------------------------------

  # FORM, protocol 5. [This is sentitive data]
  id_protocol = 5; system(paste0('rsync -av --rsh=ssh user-cscn@138.197.236.86:~/apps/uai-cscn/public/lab/public/instruments/protocols/', id_protocol, '/.data/ /home/emrys/gorkang@gmail.com/RESEARCH/PROYECTOS/2020-David-Fondecyt/jsPsych-David/jsPsychHelpeR-David/.vault/raw_data/'))

  # Protocol 1.
  id_protocol = 1; system('rsync -av --rsh=ssh user-cscn@138.197.236.86:~/apps/uai-cscn/public/lab/public/instruments/protocols/', id_protocol, '/.data/ /home/emrys/gorkang@gmail.com/RESEARCH/PROYECTOS/2020-David-Fondecyt/jsPsych-David/jsPsychHelpeR-David/data/')


# Run project --------------------------------------------------------------

  # Recreates _packages.R with the above packages (so renv founds them)
  targets::tar_renv() # Need to run renv::init() if anything changes

  targets::tar_make()

  
# Visualize targets networks -----------------------------------------------

  targets::tar_visnetwork(targets_only = TRUE, label = "time") #label = "time"
  # targets::tar_glimpse()

# Destroy cache (_targets folder) -----------------------------------------

  targets::tar_destroy()



# Invalidate a specific target (to rerun it) -----------------------------

  targets::tar_invalidate(matches("input_files"))


# See warnings in all functions ------------------------------------------
  targets::tar_meta(fields = warnings) %>% tidyr::drop_na(warnings)# See warnings



# Errors ------------------------------------------------------------------

  # If we get an error, load workspace of errored state
  targets::tar_workspace(TESTS)
  targets::tar_undebug() # Delete all the debugging stuff
  
  
  
# Data frame of targets info
  targets::tar_manifest(fields = "command")



# Load individual object
  # targets::tar_load(model_PPV)

 
 # targets::tar_outdated()
 
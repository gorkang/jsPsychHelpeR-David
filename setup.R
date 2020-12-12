
# Manual install ----------------------------------------------------------

  # The targets and tarchetypes are not yet in CRAN. 
  if (!require('remotes')) install.packages('remotes'); library('remotes')
  remotes::install_github("wlandau/targets")
  remotes::install_github("wlandau/tarchetypes")
  remotes::install_github("gadenbuie/shrtcts")

  
# Make sure all packages are present --------------------------------------

  source("_targets.R")
  missing_packages = packages_to_load[!packages_to_load %in% installed.packages()[,1]]
  
  if (length(missing_packages) > 0) {
    cat("The following packages are missing and will be installed: ", packages_to_load[!packages_to_load %in% installed.packages()[,1]])
    install.packages(packages_to_load[!packages_to_load %in% installed.packages()[,1]])
  } else {
    cat(crayon::green("All the necessary packages are present\n"))
  }


  # Make sure all the necessary folders exist -----------------------------
  
  necessary_folders = c("data", "output/data", "output/plots", "output/tables", "output/tests_outputs", ".vault", ".vault/data", ".vault/raw_data")
  if (all(necessary_folders %in% dir(recursive = TRUE, include.dirs = TRUE, all.files = TRUE))) {
    cat(crayon::green("All the necessary folders are present\n"))
  } else {
    cat(crayon::yellow("Creating necessary folders: "), paste(necessary_folders, collapse = ", "), "\n")
    invisible(purrr::map(necessary_folders, dir.create, recursive = TRUE, showWarnings = FALSE))
  }

#' check_progress_pid
#' 
#' Get list of files for a project
#'
#' @param pid 
#'
#' @return
#' @export
#'
#' @examples
check_progress_pid <- function(pid = 3) {
  
  # Secure credentials ------------------------------------------------------
  
  # Secure credentials file. ONE time
  # rstudioapi::navigateToFile(".vault/.credentials")
  # Sys.chmod(".vault/.credentials", mode = "0400")
  
  
  # Libraries ---------------------------------------------------------------
  
  # remotes::install_github("skgrange/threadr")
  # sudo apt install sshpass
  
  library(threadr)
  library(readr)
  library(ggplot2)
  library(tidyr)
  
  
  # Get filenames data from server ------------------------------------------
  
  list_credentials = source(".vault/.credentials")
  files_server = list_files_scp(host = "138.197.236.86",
                                directory_remote = paste0("/srv/users/user-cscn/apps/uai-cscn/public/lab/public/instruments/protocols/", pid, "/.data"), 
                                user = list_credentials$value$user,
                                password = list_credentials$value$password)
  
  files_csv = grep("csv", basename(files_server), value = TRUE)
  
  return(files_csv)
  
}

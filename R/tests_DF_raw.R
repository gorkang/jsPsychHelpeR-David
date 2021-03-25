##' tests_DF_raw
##'
##' .. content for \details{} ..
##'
##' @title

##' @return
##' @author gorkang
##' @export
tests_DF_raw <- function(DF_raw) {

  # # Load targets objects used in tests --------------------------------------
  # 
  # argnames <- sys.call()
  # arguments = lapply(argnames[-1], as.character) %>% unlist()

  # Load DF_clean
  targets::tar_load("DF_raw")
  
  
  # Only one project
  test_projects = 
    DF_raw %>% 
    count(project)
  
  if (nrow(test_projects) > 1) cat(crayon::red(paste0("\n\n[WARNING]: More than 1 project\n")))
  
  
  # All tasks same version!
  test_version_tasks = 
    DF_raw %>% 
    count(experimento, version) %>% 
    count(experimento) %>% 
    arrange(desc(n)) %>% 
    filter(n > 1)
  
  if (nrow(test_version_tasks) > 0) cat(crayon::red(paste0("\n\n[WARNING]: Some of the tasks have data from different versions\n")))
  
    
  # No repeated id's per experimento!
  repeated_id = 
    DF_raw %>% 
    filter(experimento != "Consent") %>% 
    count(id, experimento, filename) %>% 
    count(id, experimento) %>% 
    arrange(desc(n)) %>% 
    filter(n > 1)
  
  if (nrow(repeated_id) > 0) {
    cat(crayon::red(paste0("\n\n[WARNING]: We have repeated id's in: ")), paste(repeated_id$experimento, collapse = ", "), "\n")
    cat(crayon::red(paste0("\t\t      Offending IDs: ")), paste(repeated_id %>% distinct(id) %>% pull(id), collapse = ", "), "\n")
    stop("FIX this error before proceeding")
    
  }
  
  
  
  # CHECK -------------------------------------------------------------------
  
  DF_duplicates = suppressMessages(DF_raw %>% janitor::get_dupes(c(id, experimento, trialid)))
  
  # WARNING on duplicates
  if (nrow(DF_duplicates) > 0) {
    input_files_duplicates = DF_duplicates %>% distinct(filename) %>% pull(filename)
    warning("\n[WARNING]: There are duplicates in the '/data' input files: \n\n - ", paste(input_files_duplicates, collapse = "\n - "))
  }
  
  # IF any of the duplicates are in the Bank experiment (last task), ERROR!
  if (nrow(DF_duplicates %>% filter(experimento == "Bank")) > 0) {
    input_files_duplicates = DF_duplicates %>% filter(experimento == "Bank") %>% distinct(filename) %>% pull(filename)
    stop("\n[ERROR]: There are duplicates in the BANK experiment in the '/data' input files: \n\n - ", paste(input_files_duplicates, collapse = "\n - "))
  }
  
  DF_bank_duplicates = DF_raw %>% filter(trialid == "Bank_02") %>% count(responses) %>% arrange(desc(n)) %>% filter(n > 1)
  if (nrow(DF_bank_duplicates) > 0) {
    input_files_duplicates = DF_bank_duplicates %>% distinct(responses) %>% pull(responses)
    stop("\n[ERROR]: The following RUTs are duplicate in the BANK experiment in the '/data' input files: \n\n - ", paste(input_files_duplicates, collapse = "\n - "))
  }
  
  
  
  # No repeated trialid per id ----------------
  
  # DF_clean %>% 
  # count(id, trialid) %>% 
  # arrange(desc(n)) %>% 
  # filter(n > 1) %>% 
  # select(-n)

}
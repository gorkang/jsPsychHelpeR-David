# SENSITIVE DATA
# Function to deal with sensitive data (input files/credentials will be stored in .vault/, and NOT shared)
# We output df_AIM, which is run in a Google FORM

run_sensitive_data <- function(input_files_sensitive, df_SDG) {

  # DEBUG
  # targets::tar_load("df_SDG")
  # targets::tar_load("input_files_sensitive")
  # input_files_sensitive = list.files(path = ".vault/data_vault_5", pattern="csv", full.names = TRUE)


  # Create Bank DF ----------------------------------------------------------

    DF_raw_Bank = read_data(list.files(path = "data/", pattern = "Bank", full.names = TRUE), anonymize = FALSE)
    DF_clean_Bank = create_clean_data(DF_raw_Bank)


  # Create sensitive DF (FORM5 & AIM) --------------------------------------

    DF_raw_sensitive = read_data(input_files_sensitive, anonymize = FALSE)
    DF_clean_sensitive = create_clean_data(DF_raw_sensitive)
    
  
    # Test -----
    
      # No repeated id's per experimento!
      repeated_id = 
        DF_raw_sensitive %>% 
        count(id, experimento, filename) %>% 
        count(id, experimento) %>% 
        arrange(desc(n)) %>% 
        filter(n > 1)
      
      if (nrow(repeated_id) > 0) {
        cat(crayon::red(paste0("\n\n[WARNING]: We have repeated id's in: ")), paste(repeated_id$experimento, collapse = ", "), "\n")
        cat(crayon::red(paste0("\t\t      Offending IDs: ")), paste(repeated_id %>% distinct(id) %>% pull(id), collapse = ", "), "\n")
        stop("FIX this error before proceeding")
      }
  
  

  
  
  # Create DICCIONARIES -----------------------------------------------------
  
  # FORM5
  DF_DICCIONARY_idRUT_FORM = 
    DF_clean_sensitive %>% 
    filter(trialid == "FORM5_01") %>% 
    select(id, responses) %>% 
    rename(id_form = id,
           RUT = responses)
  
  # PROTOCOL (from df_SDG)
  DF_DICCIONARY_idRUT_PROTOCOL = 
    df_SDG %>% 
    select(id, SDG_01_RAW) %>% 
    rename(RUT = SDG_01_RAW)
  
  DF_DICCIONARY_id = 
    DF_DICCIONARY_idRUT_FORM %>% 
    left_join(DF_DICCIONARY_idRUT_PROTOCOL, by = "RUT")# %>% select(-RUT)
  
  
  # Process FORM and AIM -------------------------------------------
  
  DF_FORM_raw = prepare_FORM5(DF_clean_sensitive, DF_DICCIONARY_id, short_name_scale_str = "FORM5")
  DF_AIM_raw = prepare_AIM(DF_clean_sensitive, DF_DICCIONARY_id, short_name_scale_str = "AIM")
  DF_Bank_raw = prepare_Bank(DF_clean_Bank, short_name_scale_str = "Bank")
  


  # FORM Status -----------------------------------------------------------
  files_status = list.files(path = ".vault/data_vault_6", pattern="csv", full.names = TRUE)
  DF_FORM6 = prepare_FORM6(files_status, DF_DICCIONARY_id, short_name_scale_str = "FORM6")
  
  
  # Report ------------------------------------------------------------------
  cat(crayon::yellow("Preparando report_candidatos...\n"))
  rmarkdown::render(".vault/doc/report_candidatos.Rmd", "html_document", quiet = TRUE, clean = TRUE, envir = new.env())
  
 return(DF_AIM_raw)
  
}
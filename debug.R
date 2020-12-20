
# Read files --------------------------------------------------------------

df_FORM_RAW = read_rds(here::here(".vault/output/data/df_FORM5.rds"))
df_Status_RAW = read_rds(here::here(".vault/output/data/df_FORM6.rds"))
df_AIM = read_rds(here::here(".vault/output/data/df_AIM.rds")) %>% select(RUT, AIM_DIRt)

df_FORM_RAW
# id    RUT   id_form FORM5_01_RAW FORM5_02_RAW FORM5_03_RAW FORM5_04_RAW FORM5_05_RAW FORM5_06_RAW FORM5_07_RAW FORM5_08_RAW FORM5_09_RAW FORM5_10_RAW FORM5_11_RAW FORM5_13_RAW FORM5_01_DIR FORM5_02_DIR FORM5_03_DIR FORM5_04_DIR FORM5_05_DIR FORM5_06_DIR FORM5_07_DIR FORM5_08_DIR
# <chr> <chr> <chr>   <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>        <chr>       
#   1 NA    1525… 152569… 152569114    kkkkkk@kk.cl mmmmmmmmmm   38           Masculino    10           Taltal       999999999    No           NA           No           No           152569114    kkkkkk@kk.cl mmmmmmmmmm   38           Masculino    10           Taltal       999999999   
# 2 NA    2443… 244333… 244333168    no@gmail.com No no no     39           Masculino    3            Caldera      999999999    No           NA           No           No           244333168    no@gmail.com No no no     39           Masculino    3            Caldera      999999999   
# 3 9999… 9999… 999999… 99999999     correo@gmai… Nombre       22           Femenino     21           Vitacura     999999999    Sí           2020 protoc… No           No           99999999     correo@gmai… Nombre       22           Femenino     21           Vitacura     999999999   

df_Status_RAW
# id       RUT      datetime          FORM6_01_RAW FORM6_02_RAW id_form 
# <chr>    <chr>    <chr>             <chr>        <chr>        <chr>   
#   1 99999999 99999999 2020-12-17T123343 placeholder  placeholder  99999999

df_AIM
# RUT       AIM_DIRt
# <chr>     <chr>   
#   1 152569114 e       
# 2 244333168 d       
# 3 99999999  c2 


# Create main DF ----------------------------------------------------------

DF = 
  df_FORM_RAW %>% 
  left_join(df_AIM, by = "RUT") %>% 
  select(id, RUT, AIM_DIRt, FORM5_02_DIR, FORM5_03_DIR, FORM5_04_DIR, FORM5_05_DIR, FORM5_06_DIR, FORM5_07_DIR, FORM5_08_DIR) %>% 
  rename(
    email = FORM5_02_DIR, 
    name = FORM5_03_DIR,
    edad = FORM5_04_DIR,
    sexo = FORM5_05_DIR,
    years_education = FORM5_06_DIR,
    comuna = FORM5_07_DIR,
    telefono = FORM5_08_DIR) %>% 
  mutate(grupo = 
           case_when(
             AIM_DIRt == "d" | AIM_DIRt == "e" ~ "EXP",
             AIM_DIRt == "c2" | AIM_DIRt == "c3" ~ "CONc",
             AIM_DIRt == "c1a" | AIM_DIRt == "c1b" | AIM_DIRt == "ab" ~ "CONa",
             TRUE ~ NA_character_),
         edad = 
           case_when(
             between(edad, 25, 33) ~ "25-33",
             between(edad, 34, 42) ~ "34-42",
             between(edad, 43, 50) ~ "43-50",
             edad < 25 ~ "demasiado joven",
             edad > 50 ~ "demasiado viejo"),
         completed = 
           case_when(
             is.na(id) ~ "CALL",
             TRUE ~ "OK")) %>% 
  filter(sexo != "No binario") %>%
  filter(edad != "demasiado viejo" & edad != "demasiado joven") %>% 
  drop_na(grupo) %>% 
  select(id, RUT, completed, edad, sexo, grupo, edad, telefono, email, name, comuna)


DF
# id    RUT       completed edad  sexo      grupo telefono  email        name       comuna 
# <chr> <chr>     <chr>     <chr> <chr>     <chr> <chr>     <chr>        <chr>      <chr>  
#   1 NA    152569114 CALL      34-42 Masculino EXP   999999999 kkkkkk@kk.cl mmmmmmmmmm Taltal 
# 2 NA    244333168 CALL      34-42 Masculino EXP   999999999 no@gmail.com No no no   Caldera


df_Status =
  df_Status_RAW %>%
  mutate(date = as.Date(datetime)) %>% 
  group_by(RUT) %>% 
  summarise(status = paste(paste0("[", date, "]: ", FORM6_01_RAW), collapse = ", "),
            notes =  paste(paste0("[", date, "]: ", FORM6_02_RAW), collapse = ", "), 
            .groups = "keep")

df_Status
# RUT      status                    notes                    
# <chr>    <chr>                     <chr>                    
#   1 99999999 [2020-12-17]: placeholder [2020-12-17]: placeholder


table_candidatos_long =
  DF %>% 
  left_join(df_Status, by = "RUT") %>% 
  filter(completed == "CALL") %>% 
  drop_na(edad) %>% 
  select(grupo, edad, sexo, RUT, name, telefono, email, comuna, status, notes)

table_candidatos_long
# grupo edad  sexo      RUT       name       telefono  email        comuna  status notes
# <chr> <chr> <chr>     <chr>     <chr>      <chr>     <chr>        <chr>   <chr>  <chr>
#   1 EXP   34-42 Masculino 152569114 mmmmmmmmmm 999999999 kkkkkk@kk.cl Taltal  NA     NA   
# 2 EXP   34-42 Masculino 244333168 No no no   999999999 no@gmail.com Caldera NA     NA  


DT::datatable(table_candidatos_long, filter = 'top', 
              options = list(
                dom = 'tip',
                # autoWidth = TRUE,
                columnDefs = list(list(width = '300px', targets = c("status", "notes")))))

###************************************************************************
###************************************************************************
###                                                                     ***
###                               CODE 1:                               ***
###                         DATA PRE-PROCESSING                         ***
###                                                                     ***
###************************************************************************
###************************************************************************

##*************************************************************************
##  @project   	Validación Externa de un Score de riesgo de 4 variables   *
##              para predecir ingreso a Terapia de Reemplazo renal crónico*
##              en población adulta con enfermedad renal crónica de la Red* 
##              Asistencial Rebagliati                                    *          
##  @created   	07 de noviembre, 2021                                     *
##  @revised   	07 de noviembre, 2021                                     *
##  @category  	Importing and preparing dataset                           *
##  @R version  R version 4.1.1 (2021-08-10) -- 'Kick Things'             *
##  @OS system  MS Windows 10 Pro x 64 bits                               *
##  @author    	Percy Soto-Becerra <percys1991@gmail.com>                 *
##*************************************************************************

##****************************************************************
##  1. Configuration of environment and packages                **----
##****************************************************************

# Removing all objects including loaded libraries
rm(list = ls(all = TRUE))
gc()

# Installing and loading packages
if (!require("pacman")) {
  install.packages("pacman")
}

pacman::p_unload("all") # Unloading all package except base

if (!require("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
  BiocManager::install(version = "3.15")
}

if (!require("survcomp")) 
  BiocManager::install("survcomp")

pacman::p_load(dplyr, 
               tibble, 
               tidyr, 
               readr, 
               readxl,  
               ggplot2, 
               haven, 
               labelled, 
               forcats, 
               lubridate, 
               skimr, 
               purrr) # Loading packages


# Session Info inspection
sessionInfo()

##***************************************************************
##  2. Data input and structuring                              **----
##***************************************************************

# Importing .sav data to tibble format
# source_data <- readxl::read_excel(path = "Data/Source/scorebasefinal.xlsx")
source_data <- read.csv("Data/Source/scorebasefinal_v3_20220713.csv", sep = ";", 
                        fileEncoding = "latin1")

# Labeling values of factor variables
source_data <- source_data %>% 
  as_factor()

# Eploring original dataset
#skim(df_datum)

##***************************************************************
##  3. Data transformation                                     **----
##***************************************************************

source_data %>% 
  rename(
    nac_date = FNACIMIENTO, 
    cas = KFRE_FALLE.2019_CAS, 
    sex = SEXOC,
    age = EDAEVA, 
    assess_date = FECHAEVA, 
    crea = CREATININA, 
    eGFR_mdrd = MDRD, 
    eGFR_mdrd4 = MDRD4, 
    eGFR_ckdepi = CKD.EPI, 
    acr = RAC, 
    urine_album = ALBUMORINA, 
    urine_crea = CREAORINA, 
    death_date = FECHA_FALLECIMIENTO, 
    death = ESTADOVM, 
    death_time = TIEMPOSEGUI, 
    dial_time = TADIALISIS, 
    dial_date = FECHAINGHD, 
    dial = HD, 
    endfw = ESTADO.FINAL,
    endfw_date = FIN_SEGUIMIENTO, 
    hta = HTA, 
    dm = DM, 
    bmi = IMC, 
    album35 = ALBUM.35, 
    hemog = HEMOGLOBINA, 
    sbp_control = PAs.CONTROL, 
    dbp_control = PAd.CONTROL
    ) %>% 
  mutate(
    id = 1:n(), 
    age = floor(age), 
    cas = factor(cas), 
    sex = factor(sex, levels = c("F", "M"), labels = c("Female", "Male")), 
    male = if_else(sex == "Male", 1, 0), 
    nac_date = dmy(nac_date), 
    assess_date = dmy(assess_date),
    death_date = dmy(death_date), 
    dial_date = dmy(dial_date), 
    endfw_date = dmy(endfw_date),  
    risk2y = 1 - 0.9832 ^ exp(-0.2201 * (age / 10 - 7.036) + 0.2467 * (male - 0.5642) - 0.5567 * (eGFR_ckdepi / 5 - 7.222) + 0.4510 * (log(acr) - 5.137)), 
    risk5y = 1 - 0.9365 ^ exp(-0.2201 * (age / 10 - 7.036) + 0.2467 * (male - 0.5642) - 0.5567 * (eGFR_ckdepi / 5 - 7.222) + 0.4510 * (log(acr) - 5.137))
  ) %>% 
  dplyr::select(-dial_time, -death_time) %>% 
  mutate(
    dial_time = as.duration(assess_date %--% dial_date) / ddays(1), 
    death_time = as.duration(assess_date %--% death_date) / ddays(1), 
    end_time = as.duration(assess_date %--% endfw_date) / ddays(1)
  ) %>% 
  dplyr::select(-APELLIDOS.Y.NOMBRES, 
                -AUTOGENERADO, 
                -DNI, 
                # -nac_date, 
                -sum1, 
                -sum2, 
                -baseline.2A, 
                -baseline.5a, 
                -KFRE.2AÑOS, 
                -KFRE.5AÑOS) %>% 
  mutate(
    deathc = case_when(
      death == 0 | is.na(death) ~ 0, 
      death == 1 & death_date <= as.Date("2020-12-31") ~ 1, 
      death == 1 & death_date > as.Date("2020-12-31") ~ 0, 
      TRUE ~ as.numeric(NA)
    ),
    ddeathc = case_when(
      death_date <= as.Date("2020-12-31") ~ death_date, 
      death_date > as.Date("2020-12-31") | is.na(death_date) ~ as.Date("2020-12-31"),
      TRUE ~ as.Date(NA)
    ), 
    dialc = case_when(
      dial == 0 | is.na(dial) ~ 0, 
      dial == 1 & dial_date <= as.Date("2020-12-31") ~ 1, 
      dial == 1 & dial_date > as.Date("2020-12-31") ~ 0,
      TRUE ~ as.numeric(NA)
    ), 
    ddialc = case_when(
      dial_date <= as.Date("2020-12-31") ~ dial_date, 
      dial_date > as.Date("2020-12-31") ~ as.Date("2020-12-31"),
      is.na(dial_date) & deathc == 1 ~ ddeathc, 
      is.na(dial_date) & deathc == 0 ~ as.Date("2020-12-31"), 
      TRUE ~ as.Date(NA)
    ), 
    tdeathc = as.duration(assess_date %--% ddeathc) / dyears(1), 
    tdialc = as.duration(assess_date %--% ddialc) / dyears(1), 
    status_num = case_when(
      dialc == 0 & deathc == 0 ~ 0, 
      dialc == 1 & deathc == 0 ~ 1, #< Evento de interes: dialisis
      dialc == 0 & deathc == 1 & death_time >= 0~ 2, #< Evento en competencia (muerte antes de dialisis)
      dialc == 1 & deathc == 1 & (tdialc <= tdeathc) ~ 1, 
      TRUE ~ as.numeric(NA)
    ), 
    status_num2 = factor(status_num, levels = c(0, 1, 2), 
                         labels = c("Alive w/o Kidney Failure", 
                                    "Kidney Failure", 
                                    "Death w/o Kidney Failure")), 
    time = case_when(
      status_num == 0 ~ tdialc, 
      status_num == 1 ~ tdialc, 
      status_num == 2 ~ tdeathc, 
      TRUE ~ as.numeric(NA)
    ),
    male = as.integer(male), 
    status_num = as.integer(status_num), 
    grf_cat = case_when(
      eGFR_ckdepi > 90 ~ "G1", 
      eGFR_ckdepi >= 60 & eGFR_ckdepi <= 90 ~ "G2", 
      eGFR_ckdepi >= 45 & eGFR_ckdepi < 60 ~ "G3a", 
      eGFR_ckdepi >= 30 & eGFR_ckdepi < 45 ~ "G3b", 
      eGFR_ckdepi >= 15 & eGFR_ckdepi < 30 ~ "G4", 
      eGFR_ckdepi < 15 ~ "G5", 
      TRUE ~ as.character(NA)
    ), 
    acr2 = urine_album / urine_crea, 
    acr_cat = case_when(
      acr < 30 ~ "A1", 
      acr >= 30 & acr <= 300 ~ "A2", 
      acr > 300 ~ "A3",
      TRUE ~ as.character(NA)
    ), 
    ckd_class = case_when(
      grf_cat %in% c("G1", "G2") & acr_cat == "A1" ~ "Low risk", 
      (grf_cat %in% c("G3a") & acr_cat == "A1") | 
        (grf_cat %in% c("G1", "G2") & acr_cat == "A2") ~ "Moderately increased risk", 
      (grf_cat %in% c("G3b") & acr_cat == "A1") | 
        (grf_cat == "G3a" & acr_cat == "A2") | 
        (grf_cat %in% c("G1", "G2") & acr_cat == "A3") ~ "High risk", 
      (grf_cat %in% c("G4", "G5") & acr_cat == "A1") | 
        (grf_cat %in% c("G3b", "G4", "G5") & acr_cat == "A2") | 
        (grf_cat %in% c("G3a", "G3b", "G4", "G5") & acr_cat == "A3") ~ "Very high risk"
    ), 
    grf_cat = factor(grf_cat, levels = c("G1", "G2", "G3a", "G3b", "G4", "G5")), 
    acr_cat = factor(acr_cat, levels = c("A1", "A2", "A3")), 
    ckd_stage = case_when(
      grf_cat %in% c("G3a", "G3b", "G4") ~ "Stages 3-4", 
      grf_cat %in% c("G1", "G2", "G5") ~ "Stages 1-2 y 5"
    ), 
    ckd_stage = factor(ckd_stage, levels = c("Stages 1-2 y 5", "Stages 3-4")), 
    ckd_stage2 = case_when(
      grf_cat %in% c("G3b", "G4") ~ "Stages 3b-4", 
      grf_cat %in% c("G3a", "G5", "G1", "G2") ~ "Stages 1-3 y 5"
    ), 
    ckd_stage2 = factor(ckd_stage2, levels = c("Stages 1-3 y 5", "Stages 3b-4")), 
    ckd_class = factor(ckd_class, 
                       levels = c("Low risk", 
                                  "Moderately increased risk", 
                                  "High risk", 
                                  "Very high risk")), 
    ckd_class2 = case_when(
      ckd_class %in% c("Low risk", "Moderately increased risk", 
                       "High risk") ~ "Moderately/High risk", 
      ckd_class == "Very high risk" ~ "Very high risk", 
      TRUE ~ as.character(NA)
    ), 
    ckd_class2 = factor(ckd_class2, 
                        levels = c("Moderately/High risk", "Very high risk")), 
    across(where(is.factor), ~droplevels(.)), 
    total = 1, 
    # Censoring to 5 years----
    eventd = case_when(
      status_num2 == "Alive w/o Kidney Failure" ~ 0, 
      status_num2 == "Kidney Failure" ~ 1, 
      status_num2 == "Death w/o Kidney Failure" ~ 2, 
      TRUE ~ as.numeric(NA)
    ), 
    event = case_when(
      status_num2 %in% c("Alive w/o Kidney Failure", "Death w/o Kidney Failure") ~ 0, 
      status_num2 %in% c("Kidney Failure") ~ 1, 
      TRUE ~ as.numeric(NA)
    ),
    time_death5y = censor.time(time, deathc, time.cens = 5)$surv.time.cens, 
    death5y = censor.time(time, deathc, time.cens = 5)$surv.event.cens, 
    time_death2y = censor.time(time, deathc, time.cens = 2)$surv.time.cens, 
    death2y = censor.time(time, deathc, time.cens = 2)$surv.event.cens, 
    time5y = censor.time(time, event, time.cens = 5)$surv.time.cens, 
    event5y = censor.time(time, event, time.cens = 5)$surv.event.cens, 
    eventd5y = censor.time(time, eventd, time.cens = 5)$surv.event.cens, 
    eventd5ylab = case_when(
      eventd5y == 0 ~ "Alive w/o Kidney Failure", 
      eventd5y == 1 ~ "Kidney Failure", 
      eventd5y == 2 ~ "Death w/o Kidney Failure", 
      TRUE ~ as.character(NA)
    ), 
    time2y = censor.time(time, event, time.cens = 2)$surv.time.cens, 
    event2y = censor.time(time, event, time.cens = 2)$surv.event.cens, 
    eventd2y = censor.time(time, eventd, time.cens = 2)$surv.event.cens, 
    eventd2ylab = case_when(
      eventd2y == 0 ~ "Alive w/o Kidney Failure", 
      eventd2y == 1 ~ "Kidney Failure", 
      eventd2y == 2 ~ "Death w/o Kidney Failure", 
      TRUE ~ as.character(NA)
    )
  ) %>% 
  mutate(
    grf_cat = droplevels(grf_cat), 
    ckd_class = droplevels(ckd_class)
  ) %>% 
  set_variable_labels(
    cas = "Healthcare center", 
    sex = "Sex", 
    male = "Sex, male", 
    age = "Age (years)", 
    assess_date = "Assessment's date", 
    crea = "Creatinine", 
    eGFR_mdrd = "eGFR using MDRD", 
    eGFR_mdrd4 = "eGFR using MDRD-4", 
    eGFR_ckdepi = "eGFR using CKD-EPI", 
    acr = "Albumin-to-creatinine ratio", 
    urine_album = "Albuminuria", 
    urine_crea = "Creatinine in the Urine", 
    death_date = "Death's date", 
    dial_date = "Hemodyalisis's date", 
    endfw = "Final stage", 
    endfw_date = "Date of final follow-up", 
    hta = "Hypertension", 
    dm = "Diabetes Mellitus", 
    bmi = "Body Mass Index", 
    album35 = "Albumine", 
    hemog = "Hemoglobine", 
    sbp_control = "Systolic blood preassure", 
    dbp_control = "Dyastolic blood preassure", 
    risk2y = "Predicted risk of kidney failure to 2 years", 
    risk5y = "Predicted risk of kidney failure to 5 years", 
    grf_cat = "GFR categories", 
    acr_cat = "Persistent albuminuria categories", 
    ckd_class = "CKD KDIGO classification", 
    ckd_class2 = "CKD KDIGO classification",
    ckd_stage = "CKD Stages", 
    ckd_stage2 = "CKD Stages", 
    status_num = "Outcome", 
    status_num2 = "Outcome", 
    eventd5ylab = "Outcome at 5 years", 
    eventd2ylab = "Outcome at 2 years", 
    eventd5y = "Outcome at 5 years", 
    deathc = "Death",
    death5y = "Death at 5 years", 
    death2y = "Death at 2 years",
    time_death5y = "Time to death within 5 years", 
    dialc = "Kidney Failure", 
    total = "Total", 
    grf_cat = "GFR categories", 
    ckd_class = "CKD KDIGO classification"
    ) %>% 
  filter(age >= 18) -> derived_data

#< 1 individuo no muere pero si tuvo dialisis aunque no reportó fecha, por lo que su status y tiempos a dialisis se consideran perdidos.

derived_data %>% glimpse()

skim(derived_data)

# Validacion de datos

# ### All deaths ocurr after of dialysis not before
# sum(derived_data$death_date < derived_data$dial_date, na.rm = TRUE)
# 
# sum(derived_data$endfw_date < derived_data$dial_date, na.rm = TRUE)

# library(survcomp)


# derived_data %>% 
#   mutate(
#     dif_dates = as.duration(endfw_date %--% dial_date) /ddays(1), 
#     dif_dates2 = as.duration(endfw_date %--% death_date) /ddays(1)
#   ) %>%  
#   dplyr::select(assess_date, death, death_date, ddeathc, death_time, deathc, 
#                 dial, dial_date, dial_time, tdialc, endfw, endfw_date, 
#                 end_time, dif_dates, dif_dates2, time, status_num) -> dataq2
# 
# dataq <- derived_data %>% 
#   dplyr::select(assess_date, death, death_date, death_time, death_time2, 
#                 dial, dial_date, ddialc, dial_time, dial_time2, endfw, endfw_date, 
#                 end_time)
# # 

# Guardar datos
saveRDS(derived_data, "Data/Derived/data_derived_v2.rds")


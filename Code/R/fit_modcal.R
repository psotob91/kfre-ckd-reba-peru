fit_modcal <- function(data, value, metric, nround, nreps, ...) {
  
  data %>% 
    specify(response = value) %>% 
    calculate(stat = metric) %>% 
    as.numeric() %>% 
    round(nround) -> stat_res
  
  data %>% 
    specify(response = value) %>% 
    generate(reps = nreps, type = "bootstrap") %>% 
    calculate(stat = metric) %>% 
    get_confidence_interval(type = "percentile") %>% 
    round(nround) %>% 
    as.numeric() -> stat_ic
  
  paste0(stat_res, " (", stat_ic[1], " to ", stat_ic[2], ")") -> cal_res
  return(cal_res)
}
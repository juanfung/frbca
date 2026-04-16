library(here)
library(devtools)
library(usethis)
library(tidyverse)


#### STEPS TO TEST AND LOAD LOCAL DEV VERSION OF PACKAGE ####
## 1. usethis::proj_activate(PATH)
## 2. devtools::load_all()
## 3. devtools::document()
## 4. devtools::check()
## 5. push to gh!

## devtools::install_github(here('r/pkgs/frbca'))
## devtools::install_github("juanfung/frbca")

#########
## TODO: Add functionality to compute distributed BCRs
## TODO: Add functionality to conduct uncertainty quantification (MC?)
#########

## INCLUDE HELPER FUNCTION TO FORMAT NAMES???
my_name_repair <- function(name) {
  return(gsub('__days', '',
              tolower(gsub('(\\s+|\\(|\\?|-|/)', '_', gsub('\\)', '', name)))))
}

## test code to load data and conduct FR-BCA

path_inputs = here('data', 'processed', 'bca')

input_eal = readr::read_csv(file.path(path_inputs, 'eal_rcmf.csv'),
                            name_repair=my_name_repair) %>%
  dplyr::rename_with(~stringr::str_remove(., '__days'))

input_cost = readr::read_csv(file.path(path_inputs, 'cost_rcmf.csv'),
                             name_repair=my_name_repair) %>%
    dplyr::rename(c_s = structural, c_ns = nonstructural)

##############################################################################
## FROM SHARED DRIVE:
path_inputs = "~/gdrive-shared/nist-umd-fy23/functional-recovery/model-inputs"

input_eal = readr::read_csv(file.path(path_inputs, 'input-eal-rcmf.csv'),
                            name_repair=my_name_repair) |>
  dplyr::rename_with(~stringr::str_remove(., '__days')) |>
  dplyr::select(!construction_type)

input_cost = readr::read_csv(file.path(path_inputs, 'input-cost-rcmf.csv'),
                             name_repair=my_name_repair) |>
  dplyr::rename(c_s = structural, c_ns = nonstructural) |>
  dplyr::select(!construction_type)
##############################################################################


## RCSW:
## input_eal = readr::read_csv("../input-eal-rcsw.csv",
##                             name_repair=my_name_repair) %>%
##   dplyr::rename_with(~stringr::str_remove(., '__days'))

## ## RCMF with num_stories
## path_inputs = "../"

## input_eal = readr::read_csv(file.path(path_inputs, 'input-eal-rcmf.csv'),
##                             name_repair=my_name_repair) %>%
##   dplyr::rename_with(~stringr::str_remove(., '__days'))

## input_cost = readr::read_csv(file.path(path_inputs, 'input-cost-rcmf.csv'),
##                              name_repair=my_name_repair) %>%
##   dplyr::rename(c_s = structural, c_ns = nonstructural)

## Set analysis parameters
## NEED TO DOCUMENT
input_model_name = 'rcmf'
days = 365.25
cpi_bi = 307.1/257 # analysis year = 2023 / base year = 2019
cpi_ri = 307.1/240 # analysis year = 2023 / base year = 2016
bi_low = 0.75 ## 0.76 * cpi_bi
bi_high = 5.42 ## 5.53 * cpi_bi
rent = 22.25 / days * cpi_ri
rho = 0.87
va = 7.97 ## 7.25 * cpi_bi
delta_va = 0.035
delta_va_low = delta_va
delta_va_high = 0.12
tenant_per_area = 0.0197113

## Parameters
## floor_area = total building floor area, per story
## total_floors = total stories (NB: currently obtained from building name...not robust!)
## delta = discount rate
## T = time horizon
## bi = business income
## ri = rental income
## displacement = losses due to population displacement
## tenant = ... Need to look at notes
## recapture = business income recapture rate
## sc = supply chain losses multiplier
## TODO: read/write parameters from/to csv or json?
## Need to collect:
## {total_floors, bi_low, bi_high, ri, displacement, tenant}
## Provided defaults:
## {delta, T, recapture, sc}
bca_inputs <- list(
    model = input_model_name,
    parameters = list(
      base=list(
        floor_area=120*120,
        N = 10,
        delta=0.03,
        T=50,
        loss=list(
          loss_business_income=(bi_low+bi_high)/2,
          loss_rental_income=rent,
          loss_displacement=112,
          ## tenant=0.021,
          ## recapture=rho,
          ## loss_supply_chain=4,
          loss_value_added=va * delta_va
        ),
        ## bi=(bi_low+bi_high)/2,
        ## ri=rent,
        ## displacement=112,
        ## sc=4,
        tenant=tenant_per_area,
        recapture=rho
      ),
      sensitivity=list(
          loss=list(
            loss_business_income=list(
              low=bi_low,
              high=bi_high),
            ## loss_supply_chain=list(
            ##   low=2,
            ##   high=10),
            loss_displacement=list(
              low=53,
              high=275),
            loss_value_added=list(
              low=va * delta_va_low,
              high=va * delta_va_high)
            ),
          ## displacement=list(
          ##   low=53,
          ##   high=275),
          ## sc=list(
          ##   low=2,
          ##   high=10),
          delta=list(
                low=0.07,
                high=0.02),
            T=list(
                low=30,
                high=75)
            ## bi=list(
            ##     low=bi_low,
            ##     high=bi_high)
        )
    )
)

saveRDS(bca_inputs, here(path_inputs, 'input-param.rds'))


## testing:
params <- bca_inputs$parameters$base
mhat <- frbca::preprocess_model(input_eal, input_cost, params)
mhat1 <- mhat[[1]]
mhat11 <- mhat1[[1]]

## testing:
## preprocess_cost(input_cost)

## testing:
mhat11 %>%
    pv_dcost(bca_inputs)

## testing:
mhat11 %>%
  pv_loss(p=params) %>%
  dplyr::select(starts_with('loss'))

## testing:
mhat11 %>%
  pv_benefit(params=bca_inputs) %>%
  dplyr::select(starts_with('loss'))

## input_eal %>%
##     pv_loss(params=bca_inputs) %>%
##     dplyr::select(all_of(c('model', 'intervention', cols))) %>%
##     ## dplyr::select(model, intervention, repair_cost, displacement, business_income, rental_income) %>%
##     dplyr::rowwise() %>%
##     dplyr::mutate(loss_total=sum(across(cols))) %>%
##     ## dplyr::mutate(loss_total=sum(c(repair_cost, displacement, business_income, rental_income))) %>%
##     dplyr::ungroup() %>%
##     dplyr::filter(grepl('.*4$', model)) %>%
##     dplyr::mutate(delta_loss=loss_total[intervention == 0] - loss_total) %>%
##     dplyr::mutate(benefit=delta_loss * ((1 - (1+params$delta)^(-params$T))/params$delta)) %>%
##     dplyr::select(model, intervention, delta_loss, benefit)

## testing:

mhat11 %>%
    bcr(bca_inputs)

## testing:
set_params(bca_inputs, 'delta')

## testing:
mhat11 %>%
    sensitivity(bca_inputs)

## testing:
mhat11 %>%
    bca(bca_inputs) %>%
    dplyr::select(model, bcr)

########################
## BCA for all models ##
## testing: run analysis
frbca_rcmf <- frbca::frbca(input_eal, input_cost, bca_inputs)
########################

## test: view output
frbca_rcmf[[1]] %>%
  dplyr::select(model, bcr, label, parameter) %>%
  print(n=40)

## test: postprocessing code
postprocess_eal(frbca_rcmf[[1]], model_list=model_list)

frbca_rcmf[[1]] |>
  dplyr::filter(grepl(model_list, model) & num_stories %in% 4) |>
  dplyr::select(model, bcr, label, parameter)


frbca_rcmf[[1]] |>
  dplyr::filter(grepl("(RC|nsfr)", model) & num_stories %in% c(4)) |>
  dplyr::select(model, label, starts_with('loss')) |>
  dplyr::select(!loss_ratio) |>
  dplyr::filter(label == 'base') |>
  tidyr::pivot_longer(cols=!c('model', 'label'), names_to='loss_category', values_to='loss') |>
  dplyr::mutate(loss_category=forcats::fct_rev(loss_category))


## test: postprocessing eal
## model_list = 'baseline-(baseline|nsfr)'

model_list = paste0('RCMF-4-',
                    c('baseline-baseline',
                      'RC IV-baseline',
                      'baseline-nsfr'))

## example to create table of EALs
postprocess_eal(frbca_rcmf[[1]], model_list=model_list) |>
  dplyr::arrange(forcats::fct_rev(loss_category)) |>
  dplyr::select(loss_category, model, loss) |>
  knitr::kable()

## test: plotting eal
plot_eal(frbca_rcmf[[1]], model_list=model_list)

## test: save plot
ggsave(here::here("analysis", "output", "figs", "eal-rcmf-4.png"))

## test: postprocessing bcr
postprocess_bcr(frbca_rcmf) |>
  dplyr::mutate(parameter=forcats::fct_rev(parameter)) |>
  ggplot2::ggplot() +
  ggplot2::geom_segment(aes(x=parameter, xend=parameter, y=bcr_low, yend=bcr_high),
                        linewidth = 5, colour = "red", alpha = 0.6) +
  ggplot2::geom_segment(aes(x=parameter, xend=parameter, y=bcr-0.001, yend=bcr+0.001),
                        linewidth = 5, colour = "black") +
  ggplot2::geom_hline(yintercept=1, colour='red') +
  ggplot2::coord_flip() +
  ggplot2::facet_wrap(~model, ncol=1) +
  ## geom_hline(data=rcmf, aes(yintercept=bcr)) +
  ggplot2::theme_light() +
  ggplot2::theme(legend.position='bottom')

## test: postprocess bcr
## example to create table of BCRs
frbca_rcmf[[1]] |>
  postprocess_bcr() |>
  dplyr::mutate(parameter=forcats::fct_rev(parameter)) |>
  dplyr::select(parameter, model, bcr, bcr_low, bcr_high)

## example to create table of BCRs
postprocess_bcr(frbca_rcmf[[1]], model_list=model_list) |>
  dplyr::arrange(model) |>
  dplyr::select(model, parameter, bcr, bcr_low, bcr_high) |>
  knitr::kable()

## testing: generate bcr plot
frbca::plot_bcr(frbca_rcmf[[1]], model_list=c(model_list, "RCMF-4-RC IV-nsfr"))

## test: save plot
ggsave(here::here("analysis", "output", "figs", "sensitivity-rcmf-4.png"))


## TEST CODE: calculating IRR
frbca_rcmf[[1]] |>
  dplyr::filter(label %in% "base") |>
  dplyr::select(model, cost_diff, delta_loss, benefit, bcr, npv, irr, aroi) |>
  print(n=Inf)

dummy_delta = bca_inputs[['parameters']][['base']][['delta']]
dummy_t = bca_inputs[['parameters']][['base']][['T']]

## Not NA:
## dummy_cf = c(33114-1015000, rep(33114, dummy_t))
## NA:
dummy_cf = c((-20742)-2274000, rep((-20742), dummy_t))

npv = FinCal::npv(r=dummy_delta, cf=dummy_cf)
irr = FinCal::irr(cf=dummy_cf)

FinancialMath::IRR(cf0=dummy_cf[1], cf=dummy_cf[-1], times=1:dummy_t)

FinCal::npv(r=irr, cf=dummy_cf)

## TEST CODE: TABULATE ALL METRICS
frbca_rcmf[[1]] |>
  ## dplyr::filter(model %in% paste(c('B16', 'I16'), c(4,4,8,8,12,12), sep='-') & label %in% 'base') |>
  ## dplyr::filter(model %in% paste(c('B15', 'B16', 'I15', 'I16'), 8, sep='-') & label %in% 'base') |>
  dplyr::filter(grepl('(baseline-nsfr|IV-baseline|IV-nsfr)', model) & label %in% 'base') |>
  dplyr::select(model, cost_delta, delta_loss, bcr, npv, irr, aroi) |>
  dplyr::mutate(
           cost_delta=scales::percent(cost_delta, accuracy=0.1),
           delta_loss=scales::dollar(delta_loss),
           npv=scales::dollar(npv),
           irr=scales::percent(irr, accuracy=0.1),
           aroi=scales::percent(aroi, accuracy=0.1))


########################
## Figures
########################

## 1. Sensitivity analysis
rcmf4 <- frbca_rcmf %>%
  dplyr::filter(!is.na(bcr)) %>%
  dplyr::filter(total_floors == 4) %>%
  dplyr::select(model, bcr, label, parameter)


rcmf4_base = rcmf4 %>%
  dplyr::filter(label == 'base') %>%
  dplyr::select(!c(label, parameter))

rcmf4_sen = rcmf4 %>%
  dplyr::filter(label != 'base') %>%
  tidyr::pivot_wider(names_from=label, values_from=bcr)

rcmf4_sen <- rcmf4_sen %>%
  dplyr::left_join(rcmf4_base, by='model') %>%
  dplyr::rename(bcr_low=low, bcr_high=high)

## generate plot
plot.rcmf4 <- rcmf4_sen %>%
  ggplot() +
  geom_segment(aes(x=parameter, xend=parameter, y=bcr_low, yend=bcr_high),
               linewidth = 5, colour = "red", alpha = 0.6) +
  geom_segment(aes(x=parameter, xend=parameter, y=bcr-0.001, yend=bcr+0.001),
               linewidth = 5, colour = "black") +
  geom_hline(yintercept=1, colour='red') +
  coord_flip() +
  facet_wrap(~model, ncol=1) +
  ## geom_hline(data=rcmf, aes(yintercept=bcr)) +
  theme_light() +
  theme(legend.position='bottom') +
  labs(
    title='Sensitivity Analysis: Benefit-cost ratios for 4-story RCMF archetypes, relative to baseline ASCE 7-16 design',
    x='Parameter',
    y='Benefit-cost ratio')


## 2. Plotting EALs for status quo vs intervention(s)
## TESTING: code to plot losses
frbca_rcmf |>
  postprocess_eal() |>
  ggplot(aes(x=loss_category, y=loss, fill=model, pattern=model)) +
    ## TODO: Add text labels for dollar amounts
  ## geom_col(aes(x=loss_category, y=loss, fill=model),
  ##          position='dodge',
  ##          width=0.5) +
  ## geom_col_pattern(position="dodge",
  ##                  pattern_fill = "black",
  ##                  fill = "white",
  ##                  colour = "black",
  ##                  pattern_spacing = 0.01,
  ##                  pattern_frequency = 5,
  ##                  pattern_angle = 45) +
  geom_col(position='dodge', width=0.5) +
  ## geom_col_pattern(position='dodge') +
  ggplot2::theme_light() +
  ggplot2::theme(legend.position='bottom') +
  ggplot2::scale_y_continuous(labels = scales::label_dollar()) +
  ## TODO: Add text labels for dollar amounts
  coord_flip() +
  ggthemes::scale_fill_colorblind()
  ## scale_fill_manual(values=c('B1-4'='black', 'I1-4'='yellow', 'B15-4'='grey'))
  ## scale_pattern_manual(values=c('B1-4'='none', 'I1-4'='stripe', 'B15-4'='crosshatch')) +


###### Code updates notes ##############

## updating to dynamic list of losses
## TODO: helper function to calculate loss
## -> will need to apply dplyr::rowwise()

  ##  names_losses = names(p$econ)
  ## TODO: nested sublist with 1{re_occupancy, recovery}:
  ## p$econ$x$var * p$econ$x$time * re_occupancy_time + p$econ$x$var * (1-p$econ$x$time) * functional_recovery_time

## OLD formula for PV(benefit)
## dplyr::mutate(benefit=delta_loss * ((1 - (1+p$delta)^(-p$T))/p$delta))

## code to replace PV(NS) cost calculation

## pv_s=c_s,
## pv_ns=c_ns(1 + 1/(1-p$delta)^(p$T/2))) %>%
## dplyr::mutate(pv_total=pv_s+pv_ns)


## line to replace in plotting


#############
## plotting cost deltas

df_c = tribble(
  ~system, ~story, ~structural, ~nonstructural, ~full,
  "RCMF", 4, 0.0470, 0.0236, 0.0707,
  "RCMF", 12, 0.0503, 0.0246, 0.0749,
  "RCSW", 4, 0.0508, 0.0234, 0.0743,
  "RCSW", 12, 0.1125, 0.0246, 0.1370,
  "BRBF", 4, 0.0738, 0.0244, 0.0991,
  "BRBF", 12, 0.0838, 0.0248, 0.1086,
  "SMF", 4, 0.0654, 0.0234, 0.0888,
  "SMF", 12, 0.0804, 0.0241, 0.1045
)

df_c |>
  tidyr::pivot_longer(cols=c(structural, nonstructural, full), names_to='intervention', values_to='delta') |>
  dplyr::mutate(
           system=factor(system, levels=c("RCMF", "RCSW", "BRBF", "SMF")),
           story=factor(story),
           intervention=factor(intervention, levels=c("structural", "nonstructural", "full"))) |>
  ## ggplot(aes(x = story, y = delta, fill=intervention)) +
  ggplot(aes(x = intervention, y = delta, fill = story)) +
  geom_bar(
    ## fill = "cornflowerblue",
    ## color="black",
    stat='identity',
    width = 0.5,
    position = 'dodge') +
  ## geom_text(aes(
  ##   label = paste0(round(frac*100), "%"), y = frac),
  ##   ## label = n, y = n),
  ##   vjust = 1.4,
  ##   hjust = 1.4,
  ##   size = 5,
  ##   color = "white") +
  facet_wrap(~system) +
  labs(title = "Cost deltas for recovery-based design interventions",
       x = "System",
       y = "Cost delta") +
  ggthemes::theme_few() +
  ## theme(axis.text.y = element_text(angle = 0,  hjust = 1, size = 15)) +
  scale_y_continuous(labels = scales::percent) +
  theme(legend.position = "bottom")

## save
## ggsave(here('docs/figs/frbca-cost-deltas.png'))
ggsave(here::here("analysis", "output", "figs", "frbca-cost-deltas.png"))



## Similar plot for EALs

## - create artificial data for rcsw, using rcmf
eal_rcmf = postprocess_eal(frbca_rcmf[[1]], model_list=model_list) |>
  dplyr::filter(loss_category == 'loss_total') |>
  dplyr::mutate(story="4")

## TODO: programmatically, iterate through list object `frbca_rcmf`
eal_rcmf = dplyr::bind_rows(eal_rcmf,
                            postprocess_eal(frbca_rcmf[[3]], model_list=gsub('4', '12', model_list)) |>
  dplyr::filter(loss_category == 'loss_total') |>
  dplyr::mutate(story="12")
  )


set.seed(123)
eal_rcsw = eal_rcmf |>
  dplyr::mutate(model=gsub('^(RCMF)(.*)$', 'RCSW\\2', model),
                loss=loss+runif(n=1, min=100, max=1000))

eal = dplyr::bind_rows(eal_rcmf, eal_rcsw) |>
  dplyr::mutate(model=factor(model)) |>
  tidyr::separate(model, into=c("system", "design"), sep="-\\d+-") |>
  dplyr::mutate(design=case_when(
                  design %in% "baseline-baseline" ~ "baseline",
                  design %in% "baseline-nsfr" ~ "nonstructural",
                  design %in% "RC IV-baseline" ~ "structural"))


eal |>
  dplyr::mutate(
           system=factor(system, levels=c("RCMF", "RCSW")),
           story=factor(story, levels=c("4", "12")),
           design=factor(design, levels=c("baseline", "structural", "nonstructural"))
           ## design=factor(design, levels=c("baseline", "RC IV", "nsfr"))
           ## design=factor(design, levels=rev(c("baseline", "RC IV", "nsfr")))
         ) |>
  ggplot(aes(x = story, y = loss, fill = design)) +
  geom_bar(
    ## fill = "cornflowerblue",
    ## color="black",
    stat='identity',
    width = 0.5,
    position = 'dodge') +
  ## geom_text(aes(
  ##   label = paste0(round(frac*100), "%"), y = frac),
  ##   ## label = n, y = n),
  ##   vjust = 1.4,
  ##   hjust = 1.4,
  ##   size = 5,
  ##   color = "white") +
  facet_wrap(~system) +
  labs(title = "EALs for baseline and recovery-based designs",
       x = "Story Height",
       y = "EAL") +
  ggthemes::theme_few() +
  ## theme(axis.text.y = element_text(angle = 0,  hjust = 1, size = 15)) +
  scale_y_continuous(labels = scales::dollar) +
  ## coord_flip() +
  theme(legend.position = "bottom")

## save
ggsave(here::here("analysis", "output", "figs", "frbca-eals.png"))




## TODO: similar plot for BCRs (how to generate from output?)


## Similar plot for BCRs

## - create artificial data for rcsw, using rcmf
bcr_rcmf = postprocess_bcr(frbca_rcmf[[1]], model_list=model_list, out_base=TRUE) |>
  dplyr::mutate(story="4")

## TODO: programmatically, iterate through list object `frbca_rcmf`
bcr_rcmf = dplyr::bind_rows(bcr_rcmf,
                            postprocess_bcr(frbca_rcmf[[3]],
                                            model_list=gsub('4', '12', model_list),
                                            out_base=TRUE) |>
  dplyr::mutate(story="12")
  )


set.seed(123)
bcr_rcsw = bcr_rcmf |>
  dplyr::mutate(model=gsub('^(RCMF)(.*)$', 'RCSW\\2', model),
                bcr=bcr+runif(n=1, min=-1, max=1))

bcr = dplyr::bind_rows(bcr_rcmf, bcr_rcsw) |>
  dplyr::mutate(model=factor(model)) |>
  tidyr::separate(model, into=c("system", "design"), sep="-\\d+-") |>
  dplyr::mutate(design=case_when(
                  design %in% "baseline-baseline" ~ "baseline",
                  design %in% "baseline-nsfr" ~ "nonstructural",
                  design %in% "RC IV-baseline" ~ "structural"))


bcr |>
  dplyr::mutate(
           system=factor(system, levels=c("RCMF", "RCSW")),
           story=factor(story, levels=c("4", "12")),
           design=factor(design, levels=c("baseline", "structural", "nonstructural"))
           ## design=factor(design, levels=c("baseline", "RC IV", "nsfr"))
           ## design=factor(design, levels=rev(c("baseline", "RC IV", "nsfr")))
         ) |>
  ggplot(aes(x = design, y = bcr, fill = story)) +
  geom_bar(
    ## fill = "cornflowerblue",
    ## color="black",
    stat='identity',
    width = 0.5,
    position = 'dodge') +
  geom_hline(yintercept=1, colour="red", linetype="dashed") +
  geom_hline(yintercept=0, colour="black", linetype="solid", siz=0.5) +
  ## geom_text(aes(
  ##   label = paste0(round(frac*100), "%"), y = frac),
  ##   ## label = n, y = n),
  ##   vjust = 1.4,
  ##   hjust = 1.4,
  ##   size = 5,
  ##   color = "white") +
  facet_wrap(~system) +
  labs(title = "BCRs for baseline and recovery-based designs",
       x = "Story Height",
       y = "BCR") +
  ggthemes::theme_few() +
  ## theme(axis.text.y = element_text(angle = 0,  hjust = 1, size = 15)) +
  ## scale_y_continuous(labels = scales::dollar) +
  ## coord_flip() +
  theme(legend.position = "bottom")

## save
ggsave(here::here("analysis", "output", "figs", "frbca-bcrs.png"))


## alternative: scatter plot
bcr |>
  dplyr::mutate(
           system=factor(system, levels=c("RCMF", "RCSW")),
           story=factor(story, levels=c("4", "12")),
           design=factor(design, levels=c("baseline", "structural", "nonstructural"))
           ## design=factor(design, levels=c("baseline", "RC IV", "nsfr"))
           ## design=factor(design, levels=rev(c("baseline", "RC IV", "nsfr")))
         ) |>
  ggplot(aes(x = story, y = bcr, colour = system)) +
  geom_point() +
  facet_wrap(~design) +
  ggthemes::theme_calc()


############# TESTING MULTIPLE SYSTEMS #################
test_eal = input_eal |>
  dplyr::bind_rows(input_eal |>
                   dplyr::mutate(
                            system="RCSW",
                            model=gsub("RCMF", "RCSW", model)))

test_cost = input_cost |>
  dplyr::bind_rows(input_cost |>
                   dplyr::mutate(
                            system="RCSW",
                            model=gsub("RCMF", "RCSW", model)))

## full analysis
test_frbca <- frbca::frbca(test_eal, test_cost, bca_inputs)

## test: view output
test_frbca[[1]] |>
  dplyr::select(system, model, bcr, label, parameter) |>
  print(n=Inf)

## test: postprocessing code
test_list = c("RCMF-4-baseline-baseline")
test_table = postprocess_eal(test_frbca, model_list=test_list)

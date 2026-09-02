# analysis.R
# Project: info-agendas
# "Information, Power, and Agendas: Drivers of (In)Attention to Climate Change"
#
# Sourced by info-agendas.qmd. Builds the analysis objects the manuscript
# displays (tables/figures assembled in .qmd code chunks; some inline R).
#
# Part 1 -- Reproduce Nowlin (2019, Table 5.1): the OLS re-test of the
#   Liu, Lindquist & Vedlitz (2011) problem-stream model on congressional
#   climate-hearing counts, 1980-2016. This is the H1 baseline the paper
#   extends through 2024.

library(dplyr)
library(modelsummary)

# --- Data ------------------------------------------------------------------
# gccData.csv: annual series behind Nowlin (2019) Ch. 5, 1980-2016.
#   hearings      count of congressional climate-change hearings (DV)
#   nyt           NYT climate articles that year
#   netPPM        year-over-year change in Mauna Loa CO2 (Net Keeling Level)
#   climateIndex  U.S. Climate Extremes Index (CEI)
#   eventCount    number of international focusing events that year
#   netArticles   year-over-year change in SCI/SSCI climate publications (NSP)
#   demCongress   Democratic control of the congressional chamber (0/1)
gcc <- read.csv("data/gccData.csv", strip.white = TRUE)
names(gcc) <- trimws(names(gcc))
gcc <- gcc[order(gcc$year), ]

# Nowlin (2019) follows Liu et al. (2011) in entering the problem-stream
# variables at a one-year lag, alongside a lagged dependent variable.
lag1 <- function(x) c(NA, head(x, -1))
gcc <- gcc |>
  mutate(
    hearings_lag    = lag1(hearings),
    nyt_lag         = lag1(nyt),
    netPPM_lag      = lag1(netPPM),
    climateIndex_lag = lag1(climateIndex),
    eventCount_lag  = lag1(eventCount),
    netArticles_lag = lag1(netArticles)
  )

# --- Nowlin (2019) Table 5.1 -------------------------------------------------
m_nowlin2019 <- lm(
  hearings ~ hearings_lag + nyt_lag + netPPM_lag + climateIndex_lag +
    eventCount_lag + netArticles_lag + demCongress,
  data = gcc
)

coef_map_n2019 <- c(
  "demCongress"      = "Democratic control of chamber",
  "nyt_lag"          = "NYT articles (t-1)",
  "netPPM_lag"       = "Net CO2 level (t-1)",
  "climateIndex_lag" = "Climate Extreme Index (t-1)",
  "eventCount_lag"   = "Focusing events (t-1)",
  "netArticles_lag"  = "Net scientific publications (t-1)",
  "hearings_lag"     = "Hearings (t-1)",
  "(Intercept)"      = "Constant"
)

tbl_nowlin2019_repro <- modelsummary(
  list("Climate hearings, 1980-2016" = m_nowlin2019),
  coef_map = coef_map_n2019,
  gof_map  = c("nobs", "r.squared", "adj.r.squared"),
  stars    = c('*' = .05, '**' = .01, '***' = .001),
  output   = "modelsummary_list",
  title    = "Reproduction of Nowlin (2019), Table 5.1"
)

# --- Standalone check ------------------------------------------------------
if (sys.nframe() == 0) {
  cat("Nowlin (2019) Table 5.1 reproduction\n")
  cat("n =", length(m_nowlin2019$fitted.values),
      " (1980-2016, first year dropped by the lag)\n\n")
  print(round(summary(m_nowlin2019)$coefficients, 3))
  reported <- c(nyt_lag = 0.030, netPPM_lag = 3.743, climateIndex_lag = 0.236,
                eventCount_lag = 3.847, netArticles_lag = -0.001,
                demCongress = 11.085)
  got <- coef(m_nowlin2019)[names(reported)]
  cat("\nmax abs. difference from published coefficients:",
      formatC(max(abs(got - reported)), format = "e", digits = 2), "\n")
}

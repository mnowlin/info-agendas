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
# Part 2 -- The extended DV series, 1976-2024.
# Part 3 -- All seven Table 5.1 variables extended to 1976-2024, and the
#   model re-estimated on the full series (m_extended), alongside the
#   original 1980-2016 reproduction (m_nowlin2019) for comparison.
# Part 4 -- Liu, Lindquist & Vedlitz (2011)'s own two-equation VAR approach
#   (not Nowlin's single-equation simplification), replicated and run on the
#   full 1976-2024 series. This is the model the manuscript's Results table
#   uses.
# Part 5 -- Figures: hearings per year, and the four problem indicators.

library(dplyr)
library(modelsummary)
library(ggplot2)
library(patchwork)

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
  title    = "Reproduction of Nowlin (2019), Table 5.1"
)

# --- Extended DV series, 1976-2024 ------------------------------------------
# dv_series_1976_2024.csv: the annual count of congressional climate hearings,
# spliced across four periods/instruments (full provenance, judgment calls,
# and caveats in data/hearings-2017-2022-methodology.md):
#   1976-1979  gccHearings_deduped.csv (hand-coded) + 2 ProQuest-only
#              precedent/continuation judgment calls (memo Sec. 5a)
#   1980-2016  Nowlin (2019); same "hearings" column as gccData.csv above
#   2017-2022  GovInfo title+opening-statement content classifier, reconciled
#              against a manual-review worksheet and cross-checked against
#              ProQuest and congress.gov (memo Sec. 6a)
#   2023-2024  ProQuest title-only screen -- likely an undercount floor, no
#              opening-statement pass was available for these years (memo
#              Sec. 5, Sec. 7 item 7)
dv_series <- read.csv("data/dv_series_1976_2024.csv", strip.white = TRUE)
dv_series <- dv_series[order(dv_series$year), ]

# Sanity check: 1980-2016 in dv_series must reproduce gccData.csv$hearings
# exactly -- dv_series was built from that same source for this window, so
# any mismatch means one of the two files was edited out of sync.
chk <- merge(dv_series, gcc[, c("year", "hearings")], by = "year",
             suffixes = c("_dv", "_gcc"))
stopifnot(all(chk$hearings_dv == chk$hearings_gcc))

# --- Part 3: all seven IVs extended, 1976-2024 ------------------------------
# Provenance for each column (full detail + caveats in LOG.md and
# data/hearings-2017-2022-methodology.md):
#   netPPM, climateIndex  spliced -- original 1980-2016 values kept as-is;
#                         NOAA pulls fill 1976-1979 and 2017-2024 (negligible
#                         CO2 drift; CEI has real revision drift, spliced
#                         rather than refreshed for that reason)
#   nyt, netArticles      refreshed throughout 1976-2024 on today's NYT
#                         Article Search API / Web of Science (SCI-Expanded +
#                         SSCI) -- a splice was rejected for both: matching
#                         the original search recipe as closely as possible
#                         still produced a large, non-constant gap against
#                         the original LexisNexis/2009-era-WoS values (NYT:
#                         ~1.4x-7x, growing; sci. publications: ~7-9x,
#                         already large at the earliest overlap year), so
#                         these two now measure something closer to "content
#                         mentioning climate" than the original instruments --
#                         worth a manuscript footnote if this model is used
#   demCongress           1980-2016 unchanged; extension years use the
#                         reverse-engineered rule (unified Democratic control
#                         of both chambers -- verified against all 37
#                         original years with zero mismatches)
#   eventCount            1980-2016 unchanged; 2017-2024 from a criteria-
#                         screened re-application of Liu et al. (2011)'s own
#                         four-part IFE definition; 1976-1979 = 0 (no
#                         candidate event that early in either Liu's or
#                         Nowlin's list -- the earliest is the 1987 Montreal
#                         Protocol)
#   hearings              dv_series_1976_2024.csv (Part 2)
co2cei   <- read.csv("data/iv_co2_cei_1976_2024.csv", strip.white = TRUE)
nyt_iv   <- read.csv("data/iv_nyt_1976_2024.csv", strip.white = TRUE)
sci_iv   <- read.csv("data/iv_sciPublications_1976_2024.csv", strip.white = TRUE)
demc_ext <- read.csv("data/iv_demCongress_1976_1979_2017_2024.csv", strip.white = TRUE)
event_ext <- read.csv("data/iv_eventCount_2016_2024.csv", strip.white = TRUE)
event_ext <- event_ext[event_ext$year >= 2017, ]  # 2016 already covered by gcc

gccExt <- data.frame(year = 1976:2024)
gccExt <- merge(gccExt, dv_series[, c("year", "hearings")], by = "year", all.x = TRUE)
gccExt <- merge(gccExt, co2cei[, c("year", "netPPM_spliced", "climateIndex_spliced")],
                by = "year", all.x = TRUE)
gccExt <- merge(gccExt, nyt_iv[, c("year", "nyt")], by = "year", all.x = TRUE)
gccExt <- merge(gccExt, sci_iv[, c("year", "netArticles")], by = "year", all.x = TRUE)
names(gccExt)[names(gccExt) == "netPPM_spliced"] <- "netPPM"
names(gccExt)[names(gccExt) == "climateIndex_spliced"] <- "climateIndex"

gccExt$demCongress <- NA_real_
i <- match(gcc$year, gccExt$year)
gccExt$demCongress[i] <- gcc$demCongress
i <- match(demc_ext$year, gccExt$year)
gccExt$demCongress[i] <- demc_ext$demCongress

gccExt$eventCount <- NA_real_
i <- match(gcc$year, gccExt$year)
gccExt$eventCount[i] <- gcc$eventCount
i <- match(event_ext$year, gccExt$year)
gccExt$eventCount[i] <- event_ext$eventCount
gccExt$eventCount[gccExt$year %in% 1976:1979] <- 0

gccExt <- gccExt[order(gccExt$year), ]
stopifnot(!anyNA(gccExt))  # every column should be fully populated, 1976-2024

gccExt <- gccExt |>
  mutate(
    hearings_lag     = lag1(hearings),
    nyt_lag          = lag1(nyt),
    netPPM_lag       = lag1(netPPM),
    climateIndex_lag = lag1(climateIndex),
    eventCount_lag   = lag1(eventCount),
    netArticles_lag  = lag1(netArticles)
  )

m_extended <- lm(
  hearings ~ hearings_lag + nyt_lag + netPPM_lag + climateIndex_lag +
    eventCount_lag + netArticles_lag + demCongress,
  data = gccExt
)

tbl_nowlin_comparison <- modelsummary(
  list("Original, 1980-2016" = m_nowlin2019, "Extended, 1976-2024" = m_extended),
  coef_map = coef_map_n2019,
  gof_map  = c("nobs", "r.squared", "adj.r.squared"),
  stars    = c('*' = .05, '**' = .01, '***' = .001),
  title    = "Congressional Attention to Climate Change: Original vs. Extended Series"
)

# --- Part 4: Liu, Lindquist & Vedlitz (2011)'s two-equation VAR -------------
# Liu et al. (2011) model media attention (MA, NYT climate articles) and
# congressional attention (CA, climate hearings) as a two-equation VAR(1)
# system, each equation OLS-estimated (p. 412-413):
#   MA_t = a1 + b1 MA_t-1 + b2 CA_t-1 + b3 REP_t + b4 NKL_t-1 + b5 CEI_t-1 +
#          b6 IFE_t + b7 IFE_t-1 + b8 NSP_t-1 + e1
#   CA_t = a2 + b9 CA_t-1 + b10 MA_t-1 + b11 REP_t + b12 NKL_t-1 +
#          b13 CEI_t-1 + b14 IFE_t + b15 IFE_t-1 + b16 NSP_t-1 + e2
# A reduced-form VAR with identical regressors on both sides is equivalent
# to estimating each equation separately by OLS -- exactly how Liu et al.
# report their Table 1, and how it's done here (two lm() calls).
#
# Three deliberate departures from Part 3's Nowlin-style single equation:
#   - CA (hearings) and MA (NYT articles) are modeled jointly, each a lagged
#     predictor of the other (the interagenda-spillover test)
#   - IFE is Liu's original 0/1 dummy (an international focusing event
#     occurred that year), not Nowlin's eventCount, entered at both t and
#     t-1 -- Liu's key finding is that media responds same-year, Congress
#     responds with a lag
#   - REP is Liu's 3-level Republican-control measure (1 = GOP controls
#     both chambers, -1 = Democrats control both, 0 = split control),
#     entered with no lag -- not Nowlin's binary demCongress
# Optimal lag = 1 throughout (matching both Liu's own lag-order-selection
# result, their note 16, and Nowlin's reduced form) except REP, which Liu
# also enter unlagged.
rep_iv <- read.csv("data/iv_REP_1976_2024.csv", strip.white = TRUE)

liu <- gccExt[, c("year", "hearings", "nyt", "netPPM", "climateIndex",
                   "eventCount", "netArticles")]
names(liu) <- c("year", "CA", "MA", "NKL", "CEI", "eventCount", "NSP")
liu$IFE <- as.integer(liu$eventCount > 0)  # Liu's dummy coding, not a count
liu <- merge(liu, rep_iv[, c("year", "REP")], by = "year")
liu <- liu[order(liu$year), ]
stopifnot(!anyNA(liu))

liu <- liu |>
  mutate(
    MA_lag  = lag1(MA),
    CA_lag  = lag1(CA),
    NKL_lag = lag1(NKL),
    CEI_lag = lag1(CEI),
    NSP_lag = lag1(NSP),
    IFE_lag = lag1(IFE)
  )

m_liu_media <- lm(
  MA ~ MA_lag + CA_lag + REP + NKL_lag + CEI_lag + IFE + IFE_lag + NSP_lag,
  data = liu
)
m_liu_congress <- lm(
  CA ~ CA_lag + MA_lag + REP + NKL_lag + CEI_lag + IFE + IFE_lag + NSP_lag,
  data = liu
)

coef_map_liu <- c(
  "MA_lag"      = "Media attention (t-1)",
  "CA_lag"      = "Congressional attention (t-1)",
  "REP"         = "Republican control",
  "NKL_lag"     = "Net Keeling level (t-1)",
  "CEI_lag"     = "Climate Extreme Index (t-1)",
  "IFE"         = "International focusing event (t)",
  "IFE_lag"     = "International focusing event (t-1)",
  "NSP_lag"     = "Net scientific publication (t-1)",
  "(Intercept)" = "Constant"
)

tbl_liu_var <- modelsummary(
  list("Media Attention" = m_liu_media, "Congressional Attention" = m_liu_congress),
  coef_map = coef_map_liu,
  gof_map  = c("nobs", "r.squared", "adj.r.squared"),
  stars    = c('*' = .05, '**' = .01, '***' = .001),
  title    = "Media and Congressional Attention to Climate Change, 1976-2024"
)

# --- Part 4b: same VAR, truncated to Liu et al.'s original 1969-2005 window -
# Liu et al.'s data run 1969-2005; ours starts at 1976 (the earliest year
# ProQuest itself has any climate-hearing hit, per the DV construction --
# hearings-2017-2022-methodology.md Sec. 5a), so this is 1976-2005, not
# 1969-2005 -- the closest replication window this data supports, not an
# exact match. Same two equations, same lag structure, just the right-hand
# boundary moved to match theirs instead of running through 2024.
liu2005 <- liu[liu$year <= 2005, ]

m_liu_media_2005 <- lm(
  MA ~ MA_lag + CA_lag + REP + NKL_lag + CEI_lag + IFE + IFE_lag + NSP_lag,
  data = liu2005
)
m_liu_congress_2005 <- lm(
  CA ~ CA_lag + MA_lag + REP + NKL_lag + CEI_lag + IFE + IFE_lag + NSP_lag,
  data = liu2005
)

tbl_liu_var_2005 <- modelsummary(
  list("Media Attention" = m_liu_media_2005, "Congressional Attention" = m_liu_congress_2005),
  coef_map = coef_map_liu,
  gof_map  = c("nobs", "r.squared", "adj.r.squared"),
  stars    = c('*' = .05, '**' = .01, '***' = .001),
  title    = "Media and Congressional Attention to Climate Change, 1976-2005 (cf. Liu et al. 2011, 1969-2005)"
)

# --- Part 5: Figures ---------------------------------------------------------
fig_hearings <- ggplot(dv_series, aes(x = year, y = hearings)) +
  geom_col(fill = "#2C5F7C") +
  labs(x = NULL, y = "Number of hearings") +
  theme_minimal(base_size = 12)

.indicator_theme <- theme_minimal(base_size = 11) +
  theme(plot.title = element_text(size = 11, face = "bold"))

fig_nyt <- ggplot(gccExt, aes(x = year, y = nyt)) +
  geom_line(linewidth = 0.8, color = "#D55E00") +
  labs(x = NULL, y = NULL, title = "NYT Articles") +
  .indicator_theme

fig_nsp <- ggplot(gccExt, aes(x = year, y = netArticles)) +
  geom_line(linewidth = 0.8, color = "#0072B2") +
  labs(x = NULL, y = NULL, title = "Net Scientific Publications") +
  .indicator_theme

fig_nkl <- ggplot(gccExt, aes(x = year, y = netPPM)) +
  geom_line(linewidth = 0.8, color = "#009E73") +
  labs(x = NULL, y = NULL, title = "Net CO2 Change (Keeling)") +
  .indicator_theme

fig_cei <- ggplot(gccExt, aes(x = year, y = climateIndex)) +
  geom_line(linewidth = 0.8, color = "#CC79A7") +
  labs(x = NULL, y = NULL, title = "Climate Extremes Index") +
  .indicator_theme

fig_indicators <- (fig_nyt + fig_nsp) / (fig_nkl + fig_cei)

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

  cat("\nExtended DV series, 1976-2024 (n =", nrow(dv_series), "years)\n")
  print(dv_series)

  cat("\nExtended model, 1976-2024 (all seven IVs) -- m_extended\n")
  cat("n =", length(m_extended$fitted.values),
      " (1976-2024, first year dropped by the lag)\n\n")
  print(round(summary(m_extended)$coefficients, 3))
  cat("\nR-squared:", round(summary(m_extended)$r.squared, 3),
      " Adj. R-squared:", round(summary(m_extended)$adj.r.squared, 3), "\n")

  cat("\nLiu et al. (2011)-style VAR, 1976-2024 -- media attention (MA)\n")
  cat("n =", length(m_liu_media$fitted.values), "\n\n")
  print(round(summary(m_liu_media)$coefficients, 3))
  cat("\nLiu et al. (2011)-style VAR, 1976-2024 -- congressional attention (CA)\n")
  cat("n =", length(m_liu_congress$fitted.values), "\n\n")
  print(round(summary(m_liu_congress)$coefficients, 3))

  cat("\nLiu et al. (2011)-style VAR, 1976-2005 -- media attention (MA)\n")
  cat("n =", length(m_liu_media_2005$fitted.values), "\n\n")
  print(round(summary(m_liu_media_2005)$coefficients, 3))
  cat("\nLiu et al. (2011)-style VAR, 1976-2005 -- congressional attention (CA)\n")
  cat("n =", length(m_liu_congress_2005$fitted.values), "\n\n")
  print(round(summary(m_liu_congress_2005)$coefficients, 3))
}

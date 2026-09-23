# Information, Power, and Agendas: Drivers of (In)Attention to Climate Change

Manuscript and reproducible analysis examining how majority-party power in
Congress shapes the legislative agenda and the information environment
around climate change, and how that power drives attention to — and
inattention to — the issue.

## Layout

```
info-agendas.qmd                     Manuscript source (renders to HTML, PDF, DOCX)
_quarto.yaml                         Quarto project config
_output/                             Rendered manuscript (git-ignored build output)
_freeze/                             Quarto freeze cache (git-ignored build output)
custom-reference-doc.docx            Word reference template used for the DOCX output
LOG.md                               Running session log (newest entry first)
scripts/
  analysis.R                         Sourced by the qmd. Five parts: (1) reproduces
                                       Nowlin (2019, Table 5.1) on 1980-2016; (2) loads
                                       the extended 1969-2024 DV series; (3) extends all
                                       seven Table 5.1 variables to 1969-2024 and
                                       re-estimates (m_extended, background/not displayed
                                       in the manuscript); (4) replicates Liu et al.
                                       (2011)'s own two-equation VAR (media + congressional
                                       attention) on the full series and on Liu's exact
                                       1969-2005 window (n = 36, as in their Table 1) --
                                       this is the model the manuscript's Results section
                                       displays; (5) figures (hearings per year, the four
                                       problem indicators).
  export-cited-refs.R                Pre-render step: trims the master .bib to cited keys
data/                                Analysis data (NOT in git -- local only)
  gccData.csv                          Annual series behind Nowlin (2019, Ch. 5), 1980-2016
  gccWitnesses.csv                     Witness-appearance data, 1975-2024 (441 hearings'
                                         worth added this session from GovInfo/ProQuest;
                                         see LOG.md)
  dv_series_1969_2024.csv              The extended DV: congressional climate hearings,
                                         1969-2024 (splices GovInfo, ProQuest, and the
                                         original hand-coded series; 1969-1975 = 0 from a
                                         ProQuest hand search -- see the methodology memo
                                         below)
  iv_co2_cei_1969_2024.csv             Net CO2 change + Climate Extremes Index, spliced
  iv_nyt_1969_2024.csv                 NYT article counts, refreshed on today's API
  iv_sciPublications_1969_2024.csv     Net scientific publications (year-over-year
                                         change), spliced: original 1980-2016 kept,
                                         today's Web of Science changes for the rest
                                         (2017-2024 rescaled by 0.607)
  iv_REP_1969_2024.csv                 Liu et al.'s 3-level Republican-control measure
  iv_demCongress_1969_1979_2017_2024.csv  Nowlin's unified-Democratic-control measure,
                                         extension years only
  iv_eventCount_2016_2024.csv,
  iv_focusing_events_REVISED_2016_2024.csv  International focusing events, criteria-
                                         screened against Liu et al.'s own definition
  hearings-2017-2022-methodology.md    How the climate-hearing DV was extended (title is
                                         stale -- content covers 1976-2024; 1969-1975
                                         additions are in LOG.md, Session 6)
  transcripts_not_found.csv,
  witnesses_not_located.csv            Residual gaps (should be near-empty -- see LOG.md)
literature/                          Background literature (NOT in git -- local only)
renv.lock, renv/, .Rprofile          renv project library (tracked)
```

## Reproducing the analysis

Requires R and Quarto. Package versions are managed with `renv` (initialized);
run `renv::restore()` to reproduce the recorded library.

- **Manuscript:** `quarto render` → outputs to `_output/` (HTML, PDF, and
  DOCX; the DOCX uses `custom-reference-doc.docx`)
- **Analysis only:** `Rscript scripts/analysis.R` builds the analysis
  objects without rendering the manuscript -- see the five-part breakdown
  above.

## Data

The `data/` folder is **not tracked in git** and must be restored locally
before rendering. `data/hearings-2017-2022-methodology.md` documents how the
climate-hearing dependent variable and all seven Table 5.1 variables were
extended to 1976-2024 (its filename is stale); the 1969-1975 extension is
documented in `LOG.md` (Session 6);
`LOG.md` has the session-by-session narrative, including several data-quality
issues found and fixed along the way (worth reading before trusting any one
number in isolation). The construction scripts, intermediate files, and full
hearing-transcript corpus (657 hearings, plain text) live in
`03-data/climate-change-hearings/` (outside this repo). The 1976-2024 data files
are kept alongside the 1969 versions but are no longer read by `analysis.R`.

A separate corpus of Congressional Record floor speeches on climate change and
cap-and-trade, 2000-2012 (2,133 speeches, plain text, with party/state index),
lives in `03-data/cap-and-trade-congressional-record/` (outside this repo; see
its README for method).

## Notes

- `references.bib` and the local `.csl` are generated at render time by the
  pre-render step (`export-cited-refs.R`) from the master bibliography, so
  they are git-ignored.
- `_output/` and `_freeze/` are **git-ignored** build artifacts. Re-render
  (`quarto render`) after any change to `info-agendas.qmd` or
  `scripts/analysis.R` -- nothing under `_output/` needs to be committed.
- Quarto's freeze cache (`_freeze/`) is enabled (`execute: freeze: auto` in
  `_quarto.yaml`), so code chunks are only re-executed when the qmd or its
  upstream R sources change; delete `_freeze/` if a render looks stale.
- `literature/` and `nowlin-style-profile.md` are git-ignored (kept local
  only).
- `LOG.md` records what changed and why for each work session; add a new
  entry at the top rather than editing manuscript prose notes into commit
  messages.

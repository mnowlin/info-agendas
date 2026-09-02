# Session Log — info-agendas Project

Paper title: **"Information, Power, and Agendas: Drivers of (In)Attention to Climate Change"**

This log records what has been done in each working session. Update it at the end of each session.

---

## Project Overview

An academic article about the role of majority-party power in Congress in
shaping the legislative agenda and the information environment with regard to
climate change, and how that power drives attention to and inattention to the
issue.

**Key files:**
- `info-agendas.qmd` — main manuscript (renders to HTML, PDF, DOCX)
- `scripts/analysis.R` — data loading, analysis objects, models, and table/figure inputs sourced by the manuscript
- `scripts/export-cited-refs.R` — pre-render step that trims the master `.bib` to cited keys
- `README.md` — project structure and reproduction instructions

---

## Session History

### Session 2 — 2026-09-01/02 (Co-author, renv, Nowlin 2019 reproduction, DV extension to 2022)

- Added **Jonathan Lewallen** (University of Tampa) as co-author in the
  `info-agendas.qmd` YAML (HTML, PDF, and DOCX author blocks).
- Initialized `renv` (72 packages locked in `renv.lock`; `.Rprofile` +
  `renv/` created; R 4.6.0 recorded).
- **Reproduced Nowlin (2019), Table 5.1** in `scripts/analysis.R`: OLS of
  annual climate-hearing counts on one-year-lagged problem-stream variables
  (NYT articles, Net CO2 / Keeling change, Climate Extremes Index, focusing
  events, Net Scientific Publications), a lagged DV, and a contemporaneous
  Democratic-control term, 1980–2016. Coefficients match the published
  table to within rounding (Democratic control b = 11.085, p = .019, the
  only significant predictor). Data: `data/gccData.csv` (added this session,
  git-ignored).
- **Extended the dependent variable — the annual count of congressional
  climate hearings — from 2016 through 2022** (115th–117th Congresses).
  ProQuest Congressional (the original instrument) is unavailable, so the
  extension uses GovInfo: complete committee-scoped enumeration of a defined
  core + tail committee list, then a screen that codes each hearing on its
  title plus the opening statement of its transcript. Calibrated against
  Nowlin's 2013–2016 counts (82 vs 80; ±7/year; 79% recall). Ended at 2022
  because a congress.gov cross-check showed GovInfo transcript coverage of
  2023–2024 is only ~44–62% (publication lag). Result: 2017–2022 =
  8 / 7 / 67 / 21 / 63 / 45; full spliced series 1980–2022, n = 43.
- Wrote **`data/hearings-2017-2022-methodology.md`** — a methods memo on the
  DV extension for the co-author and peer reviewers (git-ignored; for direct
  sharing).
- Source data and all DV-construction scripts/intermediate files live in
  `03-data/climate-change-hearings/` (outside this repo) and, for the
  project-local copies, `data/` (git-ignored).
- **Still open:** the right-hand-side series in Table 5.1 (problem
  indicators, focusing events, scientific publications, media attention,
  party control) need extending from 2016 to 2022 before the model can be
  re-estimated on the full series.

### Session 1 — 2026-09-01 (Project setup)

- Ran the "set-up info-agendas" workflow from `CLAUDE.md`.
- Copied the contents of `project-files/` into the project directory.
- Renamed `template.qmd` → `info-agendas.qmd`; set the YAML `title` to the
  project title; pointed the manuscript's setup chunk at `scripts/analysis.R`.
- Set the render target in `_quarto.yaml` to `info-agendas.qmd`.
- Updated `scripts/export-cited-refs.R` to scan `info-agendas.qmd` for
  citation keys.
- Created `scripts/analysis.R` as the analysis code file (skeleton).
- Rewrote `README.md` and this `LOG.md` for the project (both had been
  copied in as templates from another project).
- Added `.gitignore` covering `data/`, `literature/`, `nowlin-style-profile.md`,
  the generated `references.bib` / `.csl`, and the usual R/Quarto build cruft.
- Initialized a git repository and made the first commit.

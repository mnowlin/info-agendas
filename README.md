# Information, Power, and Agendas: Drivers of (In)Attention to Climate Change

Manuscript and reproducible analysis examining how majority-party power in
Congress shapes the legislative agenda and the information environment
around climate change, and how that power drives attention to — and
inattention to — the issue.

## Layout

```
info-agendas.qmd                     Manuscript source (renders to HTML, PDF, DOCX)
_quarto.yaml                         Quarto project config
_output/                             Rendered manuscript (tracked in git)
custom-reference-doc.docx            Word reference template used for the DOCX output
LOG.md                               Running session log (newest entry first)
scripts/
  analysis.R                         Sourced by the qmd: loads data and builds the
                                       analysis objects, models, tables, and figures.
                                       Currently reproduces Nowlin (2019, Table 5.1).
  export-cited-refs.R                Pre-render step: trims the master .bib to cited keys
data/                                Analysis data (NOT in git -- local only)
  gccData.csv                          Annual series behind Nowlin (2019, Ch. 5), 1980-2016
  gccWitnesses.csv                     Witness-appearance data, 1975-2016 (for later use)
  hearings-2017-2022-methodology.md    How the climate-hearing DV was extended to 2022
literature/                          Background literature (NOT in git -- local only)
renv.lock, renv/, .Rprofile          renv project library (tracked)
```

## Reproducing the analysis

Requires R and Quarto. Package versions are managed with `renv` (initialized);
run `renv::restore()` to reproduce the recorded library.

- **Manuscript:** `quarto render` → outputs to `_output/` (HTML, PDF, and
  DOCX; the DOCX uses `custom-reference-doc.docx`)
- **Analysis only:** `Rscript scripts/analysis.R` builds the analysis
  objects without rendering the manuscript. It currently reproduces
  Nowlin (2019, Table 5.1) from `data/gccData.csv`.

## Data

The `data/` folder is **not tracked in git** and must be restored locally
before rendering. `data/hearings-2017-2022-methodology.md` documents how the
climate-hearing dependent variable was extended from 2016 to 2022; the
construction scripts and intermediate files live in
`03-data/climate-change-hearings/` (outside this repo).

## Notes

- `references.bib` and the local `.csl` are generated at render time by the
  pre-render step (`export-cited-refs.R`) from the master bibliography, so
  they are git-ignored.
- `_output/` **is tracked in git** (unlike most build artifacts) so the
  rendered manuscript is available without re-running R/Quarto. Re-render
  (`quarto render`) after any change to `info-agendas.qmd` or
  `scripts/analysis.R` and commit the updated files in `_output/` alongside
  the source change.
- Quarto's freeze cache (`_freeze/`) is enabled (`execute: freeze: auto` in
  `_quarto.yaml`), so code chunks are only re-executed when the qmd or its
  upstream R sources change.
- `literature/` and `nowlin-style-profile.md` are git-ignored (kept local
  only).
- `LOG.md` records what changed and why for each work session; add a new
  entry at the top rather than editing manuscript prose notes into commit
  messages.

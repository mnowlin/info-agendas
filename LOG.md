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

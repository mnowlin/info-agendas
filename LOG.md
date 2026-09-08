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

### Session 4 — 2026-09-08 (congress.gov second instrument — full enumeration + screen; DV cross-check done)

Picked up the Session 3 "START HERE" list. Steps 1–3 complete; the check is a
**shape validation, House-weighted, not a level match** — documented below.

- **Step 1 — full enumeration.** Ran
  `congressgov_enumerate_core_2017_2022.py` with no args. 8,847 committee-meeting
  detail fetches (115th–117th, both chambers), 0 errors, ~3 h. Outputs in
  `03-data/climate-change-hearings/`:
  `congressgov_core_2017_2022_enumerated.csv` (8,847 rows) and
  `congressgov_core_2017_2022_to_screen.csv` (1,683 core-committee rows).
  Final coverage: 115 House 2,272 / **115 Senate 0**; 116 House 2,219 /
  Senate 819; 117 House 2,040 / Senate 1,497.
- **Data-shape findings that constrain the check.** (a) congress.gov types
  **every** Senate committee meeting as `Meeting`, never `Hearing`; some House
  hearings too ("Oversight Hearing on …"). So a `type`-only filter is wrong —
  the screener keys on `type == "Hearing" OR "hearing" in the title`, minus
  markup/business-meeting titles. (b) Related-bill metadata is thin: 263 / 1,683
  core rows carry ≥1 bill.
- **Step 2 — wrote `screen_congressgov_core.py`.** Stage A hearing filter
  (1,683 → 1,355 hearings held; drops 181 markups, 100 business meetings, 24
  cancelled/postponed, 21 non-hearing "Meeting" rows, 2 Select-Committee
  organizational meetings; Select Committee on the Climate Crisis rule applied —
  all substantive sessions, organizational meetings only excluded). Stage B is
  the `classify_content.py` climate net (CORE / SOFT / EPA_REG / metaphor
  guard) applied to the title and — as the analog to the GovInfo opening
  statement — to related-bill titles + witnesses + doc names. Output
  `congressgov_core_screened.csv` (all 1,683 rows, `hearing_flag` +
  `climate_cls` + reasons) plus a 16-row manual-review shortlist of
  non-candidate rows that classified climate (2 are genuine House hearings
  mis-typed `Meeting` — "Sea Change: Impacts of Climate Change on Our Oceans
  and Coasts", "The Case for Climate Optimism …" — the rest are markups /
  business meetings, correctly excluded).
- **Step 3 — congress.gov series vs the GovInfo DV, 2017–2022:**

  | year | congress.gov | GovInfo DV |
  |---|---:|---:|
  | 2017 | 6 | 8 |
  | 2018 | 3 | 7 |
  | 2019 | 37 (39 w/ the 2 mis-typed) | 67 |
  | 2020 | 12 | 21 |
  | 2021 | 36 | 63 |
  | 2022 | 27 | 45 |
  | **total** | **121** | **211** |

  **Pearson r = 0.997** (year-level, raw). The instrument reproduces the
  **shape** of the series near-perfectly — 2017–18 trough, 2019 spike, 2020
  dip, 2021 rebound — from a fully independent instrument (hearings *held*,
  different vendor, no transcripts). **Level: 57–58 % recovery**, flat across
  years (2018 is small-n noise). This is at the predicted ceiling: the memo
  reports only ~64 % of GovInfo climate hearings (134 / 211) are identifiable
  from title / broad-title terms; the other ~36 % come from the opening
  statement, which congress.gov does not carry. Senate adds almost nothing to
  the climate count even where the feed has data (0/0/2/1/4/5) — Senate hearing
  titles are far less descriptive — so the instrument is House-weighted.
- **Verdict.** (a) As a reviewer-facing validity exhibit: congress.gov
  independently corroborates the **pattern** of the DV (r ≈ 1.0); it is not a
  level match, and structurally cannot be, because it cannot see content-only
  climate hearings. Honest framing: shape replicated, level gap explained by
  instrument design. (b) As a 2023–2024 carrier: congress.gov alone
  undercounts by ~40 %; it would need transcript-based opening-statement
  screening (reintroducing the GovInfo lag) or a ~1.7× calibration factor with
  its uncertainty. It is a shape check, not a drop-in replacement.
- **Not done (Session 3 step 4):** tail committees + 2023–2024 extension — not
  pursued, since the level gap makes a standalone congress.gov extension
  unattractive. Revisit only if a scaled/blended instrument is wanted.

### Session 3 — 2026-09-06 (congress.gov second-instrument prototype for the DV — PAUSED mid-task)

- Decided a **congress.gov cross-check of the 2017–2022 hearing DV** is worth
  doing, for two deliverables: (a) a parallel-instrument validity exhibit for
  reviewers (does an independent instrument reproduce the GovInfo annual
  counts?), and (b) a feasibility test of whether congress.gov alone could
  carry 2023–2024 without the GovInfo transcript-publication lag. congress.gov's
  committee-meeting feed registers hearings *held* and carries associated-bill
  metadata GovInfo lacks.
- **Wrote the core-committee enumeration prototype:**
  `03-data/climate-change-hearings/congressgov_enumerate_core_2017_2022.py`
  (outside the repo, with the other DV scripts). Enumerates every committee
  meeting for the 115th–117th Congresses (both chambers) via a per-meeting
  detail fetch, records type (Hearing/Markup/Meeting), meetingStatus, committee
  systemCodes+names, title, related-bill titles, witnesses, and doc names;
  maps to the seven **core** committees by 4-char systemCode stem
  (`hsif` `hssy` `hsii` `hlcn` = Select Committee on the Climate Crisis,
  `ssev` `sseg` `sscm`); flags a title climate keyword. Outputs
  `congressgov_core_2017_2022_enumerated.csv` (all) +
  `congressgov_core_2017_2022_to_screen.csv` (core rows, blank `include`).
  Resumable by event id. Mirrors the design of `enumerate_committees_2017_2024.py`.
- **Smoke-tested** on 120 records of the 117th (`--smoke 120`): runs clean,
  separates Hearings from Markups/Meetings, maps stems correctly, catches the
  Climate Crisis committee. Partial smoke-test CSVs were deleted; only the
  script is on disk.
- **Key finding from the API probe — congress.gov Senate coverage is the
  binding constraint.** Meeting counts: 115 House 2,272 / **115 Senate 0**;
  116 House 2,219 / Senate 819; 117 House 2,040 / Senate 1,497. The Senate
  committee-meeting feed is empty for 2017–2018 and thin for 2019–2020. So
  this instrument can validate the **House** side of 2017–2022 and likely
  carry 2023–2024, but cannot independently reproduce full-Congress counts
  for the 2017–2018 trough years.
- **START HERE NEXT SESSION:**
  1. Run the full enumeration (no args) — `cd` to
     `03-data/climate-change-hearings/`, `export GOVINFO_API_KEY=…` (same key
     var as the sibling scripts), `python3 congressgov_enumerate_core_2017_2022.py`.
     ~8,600 detail fetches, ~45–55 min; resumable.
  2. Content-screen the `…_to_screen.csv` (title + related-bill titles +
     witnesses as the analog to the GovInfo opening statement) using the
     same coding rule as `classify_content.py`.
  3. Build the congress.gov annual series and compare to the GovInfo DV
     (2017–2022 = 8 / 7 / 67 / 21 / 63 / 45); document the Senate-coverage
     gap and decide whether the check is House-only.
  4. If it reconciles, add the tail committees and test a 2023–2024 extension.

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

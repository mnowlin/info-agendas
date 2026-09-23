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

### Session 6 — 2026-09-23 (Series extended to 1969 to match Liu et al.; cap-and-trade Congressional Record corpus)

- **Extended the DV and all IVs back to 1969** so the VAR runs on exactly
  Liu, Lindquist & Vedlitz (2011)'s window (1969-2005, n = 36 after the lag).
  - **Hearings 1969-1975 = 0** — user hand-searched ProQuest Congressional
    and found no climate hearings in those years (consistent with the earlier
    exclusion of the 1975 ozone hearing in `gccHearings_deduped.csv`).
  - **CO2 / CEI:** from the same NOAA raw pulls used for 1976-1979 (1969 net
    CO2 uses the 1968 level). **REP = -1, demCongress = 1** (Democrats held
    both chambers, 91st-94th Congresses). **eventCount / IFE = 0** (Liu's
    earliest IFE is the 1987 Montreal Protocol).
  - **NYT 1969-1975:** 9, 6, 8, 13, 5, 7, 27 (NYT Article Search API, same
    query as before; `fetch_nyt_counts.py` now takes a year range).
  - **WoS 1969-1975 = 0 every year** — pulled by the user via the Claude
    Chrome extension with the same recipe (SCI-E + SSCI, AB= three terms,
    English); the same search reproduced our 1976-1979 counts exactly
    (1/1/0/2), confirming the method. Caveat: WoS barely indexes abstracts
    before 1991, so the early series undercounts.
  - New files `*_1969_2024.csv` (DV, CO2/CEI, NYT, sci publications, REP,
    demCongress) built by `extend_1969_1975.py` in
    `03-data/climate-change-hearings/` and copied to `data/`; the 1976 files
    are left in place but no longer read.
- **`scripts/analysis.R`** now reads the 1969 files; Part 4b is Liu's exact
  1969-2005 window. Ran clean; the Nowlin (2019) reproduction still matches
  (max diff 2.6e-4). **1969-2005 VAR vs. Liu's Table 1:** congressional
  attention — IFE (t-1) 8.49*** (Liu 7.23), own lag 0.47** (0.57); media —
  IFE (t) 123.3* (56.6), own lag 0.58* (0.72), NSP 0.28* (0.21); REP n.s. in
  both, as in Liu. Main difference: NSP no longer predicts congressional
  attention. Full 1969-2024 congressional equation: REP -4.34 (p = .041),
  MA (t-1) p = .002.
- **Manuscript:** updated figure/table captions to 1969 and, on request,
  the two data paragraphs (DV and IV descriptions) to say the series begins
  in 1969. Flagged, not changed: the IV paragraph describes scientific
  feedback as the *net annual change* in publications, but the refreshed
  series uses the annual count.
- **Fixed a broken renv library:** OneDrive had converted the library's
  symlinks into plain text files holding the cache path, so no package
  loaded. Recreated all 83 symlinks from renv's cache (outside OneDrive; no
  reinstall). May recur — `RENV_CONFIG_CACHE_SYMLINKS=FALSE` in `.Renviron`
  would make renv copy instead; not set yet.
- **New corpus: `03-data/cap-and-trade-congressional-record/`** (outside the
  repo) — Congressional Record floor speeches and Extensions of Remarks,
  2000-2012, on climate change and cap-and-trade.
  - Scoped first: congress.gov's API lists Record issues but has no
    full-text search, so GovInfo (same GPO files) is the instrument.
    Pre-1994 bound Record is only day-level scanned PDFs — not pursued.
  - Search terms: "climate change", "global warming", "greenhouse gas",
    "cap and trade", plus (added on request) "national energy tax" and
    "cap-and-tax" to catch opponents' framing. Plain "energy tax" left out
    (mostly energy tax credits); "carbon tax" not added (would add 26).
  - 6,846 records → 6,070 without the Daily Digest → 110,703 speeches split
    by speaker, inserted bill text stripped, 2,718 duplicate copies removed →
    **2,119 kept** by a mechanical screen (3+ mentions and 2+ per 1,000 words,
    or a topic title and 2+ mentions). Party/state from GovInfo metadata
    (all but 1 matched). Peak 2009 = 639; 277 speeches use the energy-tax
    terms, 273 of them Republican. Scripts, index CSV, full audit CSV, and
    README (method + caveats) are in that folder.

### Session 5 — 2026-09-11/12 (ProQuest trial access; DV/IV extension to 1976-2024; Liu et al. VAR replication; full transcript corpus)

Got trial ProQuest Congressional access via the university library and pulled
every hearing matching the original three-phrase search ("climate change" /
"global warming" / "greenhouse gas") across all years: 1,348 rows,
`gcc_hearings_proquest.xlsx` in `03-data/climate-change-hearings/` (a raw
keyword-hit pool, not hand-coded — same caveat as GovInfo's own full-text
search, §3.1 of the methodology memo).

- Wrote `crossmatch_proquest.py` to title-match the GovInfo-counted (211) and
  congress.gov-counted (121) 2017–2022 hearings against the ProQuest pool
  (Appropriations-committee rows excluded, per scope). Precision was good
  (85–100% of both instruments' hearings find a ProQuest match per year), but
  tracing the misses back to source surfaced **two real defects** in the
  GovInfo pipeline behind the published counts:
  1. **3 non-hearings** (a Business Meeting, an Organizational Meeting, a
     12-bill markup) auto-classified as climate hearings by
     `classify_content.py` — the same exclusion rule already applied on the
     congress.gov side had never been applied here.
  2. **31 disagreements** (within 2017–2022) between the manual `decide`
     column in `hearings_2017_2024_q_to_decide.csv` and the final automated
     classifier — the classifier was run after the manual review pass and its
     output was never reconciled against it. Includes 2 Select Committee on
     Climate Crisis hearings the Select-Committee rule says should always
     count, dropped by the classifier.
- Wrote `reconcile_content_cls_2017_2022.py`, applied both fixes (manual call
  wins on conflicts), and regenerated `content_cls_2017_2024.csv` and
  `dv_series_1980_2022.csv` in place (pre-fix copies kept as
  `*.bak-20260911-084255`). **2017–2022 climate-hearing counts: 8/7/67/21/63/45
  (211 total) → 7/4/60/17/59/40 (187 total).** congress.gov column unaffected;
  recomputed Pearson *r* = 0.998, recovery ≈ 65% (up from 57–58%).
- Updated `data/hearings-2017-2022-methodology.md` (§3.4, new §6a, §6.3, §6.4,
  §7 item 7, §8, §9 reproducibility table) to document the cross-check and the
  corrected numbers.
- **Not done:** hand-coding the ProQuest recall gap (119 GovInfo-missed / 195
  congress.gov-missed hearings, in `proquest_gap_govinfo.csv` /
  `proquest_gap_congressgov.csv`) — spot-checked as mostly incidental-mention
  noise but not verified hearing-by-hearing. §7 item 7 flags this as the
  residual open item; a 2013–2016-style calibration run directly against
  ProQuest (now possible with trial access, rather than against Nowlin's
  already-published counts) would close it more rigorously than further ad hoc
  spot-checking.
- **Downstream effect:** `scripts/analysis.R` does not yet reference
  `dv_series_1980_2022.csv` (the 2017–2022 extension isn't wired into the
  manuscript's models yet — still open from Session 2), so nothing else needed
  updating this session.
- **Same session, later:** extended the series to 2023–2024 using ProQuest
  directly (asked for by name: "add hearings from 2023 and 2024 that are in
  the file from proquest"), rather than waiting on GovInfo's transcript lag
  (previously the reason the series stopped at 2022, §5). Wrote
  `screen_proquest_2023_2024.py`: applies the same title-language climate net
  (`classify_content.py`'s CORE/SOFT/EPA-reg regexes) to the 76 non-Appropriations
  ProQuest 2023–2024 titles (title-only — ProQuest's pull has no transcript
  text, so no opening-statement pass, same ceiling as the congress.gov
  cross-check §6), plus 2 manual-override carryovers from
  `hearings_2017_2024_q_to_decide.csv` for titles the regex missed but a human
  reviewer had already confirmed on the matching GovInfo hearing. **Result:
  2023 = 19, 2024 = 13.** New `dv_series_1980_2024.csv` (45 obs, 1980–2024)
  supersedes `dv_series_1980_2022.csv`. Updated the methodology memo (§5
  rewritten, §7 new item 7, §8, §9) — its filename/title are now stale (still
  says "...to 2022") and should be renamed in a future session if the 2023–2024
  extension sticks.
- **Flagged, not resolved:** 2023–2024 is a title-only screen and should be
  read as a floor (§7 item 7); 3 other manual 'include' calls for 2023–2024
  hearings from the GovInfo worksheet aren't in the ProQuest pull at all, so
  couldn't be cross-checked. A content-based recount (GovInfo transcripts, once
  published, or ProQuest abstracts if accessible) would likely raise both years.
- **Same session, later still:** asked "the dv series should start in 1976 per
  the proquest results. check." Confirmed: 1976 is the earliest year with any
  ProQuest hit (nothing in 1975). Also discovered `gccHearings_deduped.csv` is
  the literal hand-coded source behind the published "Nowlin2019_ProQuest"
  portion of the series (year counts match `dv_series` exactly for 34/43 years,
  1980–2016) and already has un-used entries for 1975, 1976, and 1979 — the
  series stopped at 1980 to match Nowlin's published table window, not for lack
  of earlier data. Wrote `extend_dv_1976_1979.py`: 1975 excluded (no ProQuest
  corroboration, per the instruction); **1976 = 2, 1977 = 1, 1978 = 0, 1979 = 3**
  (1976/1977 partly hand-coded, partly ProQuest-only on precedent/continuation
  judgment calls — see `pre1980_extension_1976_1979.csv`; 1979 = all 3
  hand-coded hearings, trusted even though ProQuest has nothing that year,
  same basis as the rest of 1980–2016). New `dv_series_1976_2024.csv` (49 obs.)
  supersedes `dv_series_1980_2024.csv`. Updated the methodology memo (new §5a,
  §8, §9, §7 item 8).
- **Flagged for a second look:** the 1976/1977 ProQuest-only judgment calls
  (methodology memo §7 item 8) — small in magnitude (2 hearings total) but not
  hand-coded, worth a sanity check before relying on the exact early-series
  counts.
- **Same session, later still:** wired `dv_series_1976_2024.csv` into
  `scripts/analysis.R` (copied into `data/`, git-ignored like `gccData.csv`).
  Added a `dv_series` object plus a `stopifnot` sanity check that its
  1980–2016 values reproduce `gccData.csv$hearings` exactly (they do). The
  Nowlin (2019) Table 5.1 model itself still runs on 1980–2016 / `gccData.csv`
  only — the RHS problem-stream variables aren't extended past 2016 yet (still
  open, Session 2) — so `dv_series` is descriptive-only for now, ready for a
  manuscript table/figure. Ran `Rscript scripts/analysis.R` to confirm it
  sources cleanly end to end.
- **Same session, later still:** extended `gccWitnesses.csv` (Nowlin's
  hand-coded witness dataset, previously 444 hearings / 3051 witness rows,
  1975–2016) to cover the 197 hearings added to the DV series this session
  that had no witness data yet (187 GovInfo 2017–2022 + 32 ProQuest 2023–2024
  + 2 ProQuest-only pre-1980 judgment calls, minus 24 not located — see
  below). Wrote `fetch_new_witnesses.py`
  (`03-data/climate-change-hearings/`): pulls witness lists from GovInfo's
  `packages/{id}/granules/{id}/summary` API (already cached for most
  2017–2022 hearings in `pool_content.csv` from earlier sessions; fresh
  GovInfo title search for 2023–2024 and the 2 pre-1980 hearings, ~32/34
  found directly), then a rule-based classifier reverse-engineered from
  `gccWitnesses.csv`'s own affiliation → affiliation3 crosstab (fed agency
  name list, congress/Senator-Representative pattern, academic/think-tank/
  national-lab keyword list, an explicit environmental-org name list,
  state/local-government patterns, international-body patterns, and
  industry-sector keyword buckets for the private-sector catch-all).
  **This is a best-effort automated classifier, not a re-run of Nowlin's hand
  coding** — reliable at the broad affiliation3 level, less certain at the
  fine-grained affiliation/affiliation2 levels the original scheme
  distinguishes (e.g. 'tank' vs 'ins' vs 'profess' within "expert"). New rows
  carry a `notes` column (`auto-coded 2026-09-11; source=...;
  govinfo_package=...`) — blank for the original 3051 hand-coded rows — so
  they can be filtered and spot-checked; **flagged for review, not treated as
  final.** Also fixed two real bugs surfaced along the way: GovInfo returns
  `witnesses` as a plain string (not a list) for at least one package
  (CHRG-117hhrg44473), which a naive `" | ".join()` was silently exploding
  into one row per character; and witness-name order flips between
  "First Last" and "Last, First" across hearings/years with no field marking
  which, requiring a name-shape heuristic to avoid corrupting names like
  "Curry, Judith A." or "Dr. Ted Gayer, PhD."
  **Result: 973 new witness rows across 197 hearings.** Backed up the prior
  `gccWitnesses.csv` as `gccWitnesses.csv.bak-20260911-092532` before merging.
- **Separate list for manual follow-up (as asked):** `witnesses_not_located.csv`
  (24 hearings) — mostly Select Committee on Climate Crisis hearings whose
  GovInfo transcripts are PDF-only with no extractable text/witness metadata
  (confirmed via a direct API check, not just a cache miss), plus a few 2019
  hearings with the same gap, 5 ProQuest 2023–2024 hearings with no matching
  GovInfo package yet, and the 2 pre-1980 ProQuest-only hearings. Copied into
  `data/witnesses_not_located.csv` for pulling from ProQuest.
- **Same session, later still:** asked what the 2019 "Member Day Hearing" was
  (found while browsing the new witness rows). It's **CHRG-116hhrg45261**
  (House Energy and Commerce, 2019-07-25) — a procedural hearing type the
  116th Congress's House rules package newly required, where Members *not* on
  the committee give brief opening statements on unrelated priorities; its
  ~40 "witnesses" are just those Members. It was coded a climate hearing only
  because Chairman Pallone's opening statement listed "combat climate change"
  among several general committee goals — same failure mode as the 3
  non-hearing contaminants found in the §6a reconciliation, just missed
  because it *is* a real hearing. **Excluded on request.** Checking for the
  same title pattern found 2 more: **CHRG-117hhrg51884** ("Member Day,"
  same committee, 2021-06-13, same Pallone-boilerplate pattern) — also
  excluded — and **CHRG-116hhrg39860** ("Member Day," **Select Committee on
  the Climate Crisis**, 2019-11-14) — kept, since that committee's Member Day
  was explicitly "to hear from our colleagues... about their best ideas to
  solve the climate crisis," a genuine climate hearing under the existing
  Select-Committee rule. **Net: 2017–2022 total 187 → 185 (2019: 60 → 59,
  2021: 59 → 58)**; 46 witness rows removed from `gccWitnesses.csv` for the
  two excluded hearings. Updated `content_cls_2017_2024.csv`,
  `dv_series_1976_2024.csv` (both copies), `gccWitnesses.csv`,
  `gccWitnesses_additions.csv`, and the methodology memo (§6a, §6.3, §8, §7
  item 9), each backed up before editing. Re-ran `Rscript scripts/analysis.R`
  to confirm it still sources cleanly. **Flagged as a residual risk:** this
  was a manual, ad hoc find (checked only the "Member Day" title pattern) —
  not a systematic re-screen for other single-topic-mention procedural
  hearings.
- **Same session, later still:** downloaded plain-text hearing transcripts
  for every hearing behind `dv_series_1976_2024.csv` into
  `03-data/climate-change-hearings/hearing-transcripts/`, named by ProQuest
  HearingID as asked. Wrote `build_transcript_target_list.py` (resolves each
  DV hearing to a ProQuest HearingID via fuzzy title match, and a GovInfo
  package_id from already-known sources — `gcc_crossmatch.csv` for
  1980–2016, `content_cls_2017_2024.csv` for 2017–2022 — leaving the rest to
  a fresh search) and `fetch_hearing_transcripts.py` (HTML transcript, else
  PDF text-layer extraction, else the package zip's embedded PDF for the
  oldest hearings; resumable). Caught and fixed a duplicate-target bug before
  the real run (4 hand-coded 1976/1979 hearings were being double-counted
  across two source files) and a very slow first attempt turned out to just
  be large old-hearing PDF downloads, not a hang — reran detached in the
  background. **Result: 509 saved, 3 already on disk, 149 not found** (out
  of 661 DV hearings, 1976–2024). 89% of the misses are pre-1990 hearings —
  matches the known GovInfo full-text-index gap for that era (SESSION_LOG.md
  §5) — GovInfo has no resolvable package for any of them, not a fetch
  failure on a known package. `transcripts_not_found.csv` copied to
  `data/transcripts_not_found.csv` for a ProQuest pull, as asked.
- **Same session, later still:** IV inventory. Found the original Nowlin
  (2019) chapter source (`Published Research/Environmental Policy Book/
  Chap 4 Agenda Setting/` — `chap4FINAL.Rmd`, `agenda.R`, `TABagenda.tex`),
  confirming the exact Table 5.1 formula and every IV's provenance rather
  than reconstructing it. Listed for the user: NYT articles (LexisNexis),
  net CO2 (Mauna Loa/Scripps), Climate Extreme Index (NOAA), net scientific
  publications (Web of Science), focusing events (hand-coded list),
  Democratic chamber control, lagged DV — all end at 2016 and need
  extending to 2024. `envMood`/`votes` are in `gccData.csv` but aren't in
  the Table 5.1 formula; `energy`/`landUse`/`transportation`/`science`/
  `international`/`impacts` are subtopic-DV robustness models, not IVs.
- **Same session, later still:** pulled CO2 and CEI, 1976–2024.
  CO2: NOAA GML annual mean, Mauna Loa (`co2_annmean_mlo.txt`) — matches
  `gccData.csv`'s original 1980–2016 `avgPPM` almost exactly (<0.5 ppm
  drift, negligible). CEI: NOAA NCEI's "Without Tropical Cyclone Indicator,"
  Annual, Contiguous U.S. (found via the CEI graph tool's `data.csv`
  endpoint — the TC-inclusive variant numerically did not match
  `gccData.csv` at all, despite the chapter text describing tropical-cyclone
  wind as a CEI component). **CEI has been meaningfully revised by NOAA
  since 2018**: close through the 1990s, but up to ~4.6 points off by the
  2000s–2010s (e.g. 2016: 44.22 original vs. 40.06 today). Built
  `iv_co2_cei_1976_2024.csv` with both a **spliced** series (keeps the
  original 1980–2016 values, only appends new 1976–1979/2017–2024 pulls —
  recommended, preserves continuity with the published Table 5.1) and a
  **fully refreshed** series (today's NOAA values throughout) for
  comparison. Raw pulls archived as `noaa_co2_annmean_mlo_raw.txt` /
  `noaa_cei_us_annual_raw.csv` in `03-data/climate-change-hearings/`.
  **Not yet wired into `analysis.R`** — waiting on the splice-vs-refresh
  call and the remaining IVs (NYT, sci publications, focusing events,
  demCongress) before touching the model.
- **Same session, later still:** worked the remaining IVs.
  - **`demCongress` fully reverse-engineered.** Found `gccFinal2.csv` in the
    Nowlin (2019) chapter source, which has a per-hearing `demMajority`
    field (committee chair's party). Neither House-only nor Senate-only
    control matched `gccData.csv`'s annual `demCongress` values. The actual
    rule: **`demCongress` = 1 iff Democrats hold unified control of both
    chambers that year** (not "the chamber holding the hearing," as the
    chapter prose states) — verified with **zero mismatches across all 37
    years, 1980–2016**. Extended with full confidence:
    1976–1979 = 1 (unified Dem 94th–96th Congresses); 2017–2018 = 0 (115th,
    unified R); 2019–2020 = 0 (116th, split); 2021–2022 = 1 (117th, unified
    D, 50-50+VP); 2023–2024 = 0 (118th, split). Written to
    `iv_demCongress_1976_1979_2017_2024.csv`.
  - **Focusing events: a draft list only**, not a confident extension —
    this is a judgment call in the original methodology too. Compiled
    `iv_focusing_events_DRAFT_2016_2024.csv` (13 candidate events, 2016–2024:
    Paris Agreement entry into force, US withdrawal/rejoining, IPCC SR1.5/
    AR6 reports, 4th/5th National Climate Assessments, COP26–29, the
    Inflation Reduction Act) explicitly flagged for the user's review before
    use — two entries (the 2017 withdrawal, the 2022 IRA) are a different
    *type* of event than anything in Nowlin's original list (domestic
    policy/legislative, not international treaty/IPCC/assessment
    milestones), noted inline.
  - **NYT articles and net scientific publications: blocked on
    credentials**, not attempted. NYT counts came from LexisNexis
    originally; the NYT Developer API (free key, ~2 min signup at
    developer.nytimes.com) could reproduce a comparable count but I have no
    key. Scientific publications came from Web of Science (institutional,
    like the original ProQuest access) — no free equivalent matches that
    methodology; OpenAlex (fully open, no key) could serve as a same-search-terms
    stopgap but is a different index/count scale, not a drop-in replacement.
    Waiting on the user for either a NYT API key or a decision on the
    publications source.
- **Same session, later still:** got a NYT Developer API key from the user,
  pulled NYT article counts, 1976–2024. Confirmed the API's `q` parameter
  doesn't support boolean OR across the 4 search phrases (returned ~1 hit
  for what should be thousands) — had to use `fq` (Lucene syntax) instead,
  verified against a manual single-phrase-vs-OR-combined comparison.
  Fetched via `fetch_nyt_counts.py`, paced at 13s/request for the 5/min free
  tier (`iv_nyt_1976_2024.csv`, also in `03-data/climate-change-hearings/`).
  **Finding, more serious than the CO2/CEI drift:** the NYT's own Article
  Search API consistently returns *more* hits than the original
  LexisNexis-sourced `nyt` column, and the gap **grows over time** rather
  than holding roughly steady — about 1.4–2.3x in the 1980s–90s, climbing to
  5–7x by the 2000s–2010s (mean ratio 2.86x across 1980–2016, e.g. 2016:
  690 original vs. 1,764 new). Tried restricting to `type_of_material`/
  `document_type` "article" or "News" to narrow it (multi-`fq` combination
  didn't take, second filter was silently dropped) — not resolved before
  stopping to flag this rather than keep guessing at query syntax. **Did not
  build a spliced/refreshed output or pick a default** the way the CO2/CEI
  IVs got one — a growing multi-year trend in the mismatch makes both a
  naive splice (fake discontinuity at 2016/2017) and a naive full refresh
  (breaks comparability with the published Table 5.1 coefficient scale)
  bad defaults here. Reported to the user for a decision: pursue
  institutional LexisNexis access (parallel to the ProQuest/Web of Science
  asks), or accept the NYT API and refresh the whole 1976–2024 series on
  it (re-estimating, not just extending, that coefficient).
- **Same session, later still:** asked to dig into whether the growing
  NYT-API-vs-LexisNexis ratio was a coverage-scope artifact (blogs/
  interactives) before deciding. Confirmed it isn't: sampled 100 2016
  results and 50 1990 results -- `document_type` is 99%/100% plain "article"
  both years, interactive/multimedia content is ~1% even in 2016, nowhere
  near enough to explain a 5-7x gap. Also confirmed all field-restricted
  `fq` queries (`document_type`, `type_of_material`, `news_desk`, even
  `source`) return 0 hits regardless of value -- field filtering appears
  broken/removed from the current API, not a syntax issue, so there is no
  server-side way to narrow the search scope further. Most likely real
  explanation: the NYT's own full-text index matches the phrase anywhere in
  the full article body, while the original LexisNexis pull was probably
  scoped narrower (headline/lead/subject-tag) -- the same incidental-mention
  inflation problem already seen with GovInfo's full-text search and the
  raw ProQuest pool earlier in this project, just on a different corpus.
  **Decision: refresh the whole 1976-2024 series on the NYT API** (not a
  splice). Rebuilt `iv_nyt_1976_2024.csv` with the NYT API count as the
  primary `nyt` column (original LexisNexis values kept alongside for
  reference, not used). Flag for the manuscript: this changes what the
  variable measures -- closer to "NYT content mentioning climate" than "NYT
  climate coverage" -- worth a footnote if this series feeds the
  re-estimated model.
- **Same session, later still:** asked to read Liu et al. (2011) itself for
  their international-focusing-event (IFE) guidelines and check whether
  that can be recreated/extended, rather than freehand judgment calls. Found
  a local PDF (`00-info-agendas/raw/Liu et al. - 2011...pdf`) and read it in
  full. **Good news relative to NYT/WoS: fully reproducible, no paywalled
  access needed.** Liu's IFE definition is an explicit four-criteria test
  (p. 410-411): (1) creation of an unprecedented international agreement/
  protocol/treaty; (2) establishment of a new international/intergovernmental
  institution; (3) a worldwide high-profile convention/conference; (4)
  release of a new landmark-type assessment by a reputable *international*
  scientific organization -- plus an explicit rule (note 10) excluding
  *routine* recurring events (they counted only the first 3 UNFCCC COPs;
  post-Kyoto COPs were "routine" unless producing something unprecedented).
  Also surfaced two things Nowlin already changed from Liu's original: Liu
  coded IFEs as a 0/1 dummy (`event` in `gccData.csv`, kept for a
  Liu-comparable robustness check); Nowlin switched to a raw count
  (`eventCount`) for his main model. And Nowlin already extended past Liu's
  strict "international" requirement by including US-domestic National
  Climate Assessments and *An Inconvenient Truth* -- his own precedent for
  reasonable extension, not licensed by Liu's 4 criteria itself.
  **Re-screened the earlier 2016-2024 draft against the real criteria** in
  `iv_focusing_events_REVISED_2016_2024.csv` -- several of my earlier draft
  entries don't actually qualify and were dropped: Paris entry-into-force
  (2016, procedural, not a new creation), the US Paris withdrawal (2017) and
  rejoining (2021, both unilateral national actions), the IRA (2022,
  domestic legislation, no precedent in either Liu's or Nowlin's lists), and
  COP29 (2024, marginal -- outcome widely seen as inadequate, not clearly
  "unprecedented"). Recommended list: 2018 (IPCC SR1.5 + 4th NCA) = 2;
  2021 (IPCC AR6 WG1 + COP26 Glasgow) = 2; 2022 (COP27 Loss and Damage
  Fund) = 1; 2023 (COP28 Global Stocktake + 5th NCA) = 2; all other years
  2016-2024 = 0. **Flagged, not resolved:** the AR6 Synthesis Report (2023)
  is the same assessment cycle as the already-counted 2021 WG1 report --
  Liu/Nowlin counted each IPCC assessment once per cycle, so pick one date,
  not both.
- **Same session, later still:** user chose the 2021 WG1 date for AR6 (not
  the 2023 Synthesis). Hit a bug fixing this: a round-trip through Python's
  csv module choked on an unquoted comma in one verdict string ("FLAG - pick
  ONE date... Synthesis), not both") and truncated
  `iv_focusing_events_REVISED_2016_2024.csv` from 13 rows to 5 (only the
  KEEP rows before the bad one survived) before the exception surfaced --
  caught it by checking the file directly rather than trusting the script
  output, rebuilt it cleanly with every field quoted. Final recommended
  `eventCount`, 2016-2024: 2018 = 2 (SR1.5 + 4th NCA), 2021 = 2 (AR6 WG1 +
  COP26), 2022 = 1 (COP27), 2023 = 2 (COP28 + 5th NCA), all other years = 0.
  Written to `iv_eventCount_2016_2024.csv` (7 KEEP events total; the full
  13-row `iv_focusing_events_REVISED_2016_2024.csv` keeps every DROP
  decision and its reasoning for the audit trail).
- Same session, later still: wrote a Web of Science search prompt for
  the user's Claude Chrome extension (their institutional WoS access, same
  pattern as ProQuest) reproducing Liu et al. (2011)'s exact recipe: SCI-
  Expanded + SSCI only, the same 3 terms OR'd in the Abstract field, English
  only, no author-country or document-type restriction, one year at a time.
  User ran it and reported back per-year counts, 2014-2024, confirming the
  same index scope on every run. Result: worse than the NYT gap. The
  2014-2016 overlap against gccData.csv's existing netArticles
  (1,383 / 1,758 / 1,493) is 7-9x higher in the new pull
  (10,885 / 11,950 / 13,586) -- not a modest drift, a different order of
  magnitude across the whole overlap window, even with the search recipe
  matched as closely as documentation allows. Saved the full comparison to
  iv_sciPublications_1976_2024.csv (original cumulative/annual columns plus
  the new WoS annual counts, not merged/decided). Most likely explanation
  (not independently verified -- would need the user's own memory of the
  original pull, or WoS access this session doesn't have): Web of Science's
  SCI-Expanded/SSCI journal coverage has grown substantially since Liu's
  2009-era pull (their footnote 11 cites ~5,900 SCI / ~1,725 SSCI journals;
  both indexes are meaningfully larger today), on top of "climate change"
  becoming a much more common abstract term across all of science generally
  -- the same corpus-growth/incidental-mention pattern as the NYT finding,
  now on a scientific-literature corpus instead of a newspaper one. Not
  decided: reported to the user for the same splice/refresh/dig-deeper call
  as NYT.
- Same session, later still: user chose to refresh the whole series on WoS.
  That required WoS counts for 1976-2013 too (the first Chrome-extension
  pull only covered 2014-2024) -- otherwise the same 7-9x discontinuity just
  moves to the 2013/2014 boundary instead of being fixed. Sent a follow-up
  Chrome-extension prompt using the same validated recipe, but via WoS's
  "Publication Years" facet/breakdown on a single unrestricted 1976-2013
  search rather than 38 separate one-year searches -- user confirmed the
  facet method reproduces the individual-search numbers exactly for the
  2014/2015 validation check (10,885 / 11,950, identical), and the 38
  per-year facet counts sum exactly to the unrestricted search's total
  (61,813), so no double-counting/dropping in the breakdown method. Full
  1976-2024 WoS annual counts now in hand. Built the final
  iv_sciPublications_1976_2024.csv: netArticles = the new WoS annual count
  directly (this is what lag(netArticles,-1) uses in the Table 5.1 formula);
  also reconstructed a running sciArticles cumulative total from 1976
  forward for reference/consistency with gccData.csv's two-column structure
  (1976-2024 cumulative = 330,805). Original WoS-era values kept alongside
  for reference, not used. All seven IVs are
  now resolved (CO2 spliced, CEI spliced, NYT refreshed, sciPublications
  refreshed, demCongress reverse-engineered, focusing events criteria-
  screened, lagged DV automatic).
- Same session, later still: wired all seven into scripts/analysis.R as a
  new Part 3. Reads iv_co2_cei_1976_2024.csv, iv_nyt_1976_2024.csv,
  iv_sciPublications_1976_2024.csv, iv_demCongress_1976_1979_2017_2024.csv,
  and iv_eventCount_2016_2024.csv, merges them onto dv_series (Part 2) into
  a new gccExt data frame (1976-2024, 49 rows), with a stopifnot(!anyNA(...))
  check that every column is fully populated before modeling. Re-estimated
  the Table 5.1 formula on the full series as m_extended (n = 48 after the
  lag) alongside the untouched original m_nowlin2019 (n = 36, still
  reproducing the published coefficients exactly). Added
  tbl_nowlin_comparison (a modelsummary side-by-side of both models) and
  extended the standalone diagnostic block to print m_extended's summary.
  Ran clean end to end. Result, for the record (not yet interpreted for the
  manuscript): adj. R-squared rises to .50 (from .457); nyt_lag
  (p = .001), eventCount_lag (p = .005), and demCongress (p = .033) are
  all significant in the extended model, vs. only demCongress in the
  original -- expected given the NYT/sci-publications refresh changed those
  two variables' scale, so this shift in significance pattern should be read
  with that construct-change caveat (documented inline in analysis.R and in
  the IV entries above), not as a clean replication finding.
- Same session, later still: the user added section headers and figure/table
  requests directly to info-agendas.qmd, including "use the same modeling
  approach as @liuExplainingMediaCongressional2011." Re-read the article's
  actual method (VAR modeling section, p. 412-413) rather than assuming
  Nowlin's single-equation OLS was equivalent to it. Liu et al.'s real
  approach is a two-equation system -- media attention (MA, NYT articles)
  and congressional attention (CA, hearings) each regressed on the other's
  lag plus the problem-stream variables, OLS-estimated equation-by-equation
  (a reduced-form VAR with identical regressors on both sides is exactly
  equivalent to two separate lm() calls, which is how Liu et al. actually
  report their Table 1). Built this as a new Part 4 in analysis.R, distinct
  from Part 3's Nowlin-style single equation:
  - Built iv_REP_1976_2024.csv: Liu's own Republican-control measure (1 =
    GOP controls both chambers, -1 = Democrats control both, 0 = split) --
    different from demCongress (unified-Democratic-only 0/1), needed the
    full House+Senate control history reconstructed by year.
  - IFE uses Liu's original 0/1 dummy (any focusing event that year), not
    Nowlin's eventCount, entered at both t and t-1 -- reproduces Liu's own
    finding almost exactly: IFE(t) is significant in the media equation
    (p=.039) and IFE(t-1) is significant in the congressional equation
    (p=.015), matching their "media reacts immediately, Congress reacts
    with a lag" result.
  - REP entered with no lag (per Liu's explicit choice); MA/CA/NKL/CEI/NSP
    all at lag 1 (per Liu's own lag-order-selection result and Nowlin's
    reduced form).
  m_liu_media and m_liu_congress (n=48 each) plus tbl_liu_var (a
  modelsummary side-by-side) are the objects the manuscript's Results table
  now uses; m_nowlin2019/m_extended (Part 3) are left in place as
  background/robustness objects but are not displayed, per "do not include
  nowlin 2019 results."
  Also built fig_hearings (bar chart, hearings/year 1976-2024) and
  fig_indicators (2x2 patchwork panel: NYT articles, net scientific
  publications, net CO2 change, CEI). Installed ggplot2 + patchwork via
  renv::install() and renv::snapshot() (weren't in the project before).
  **Caught and fixed a real bug**: all three modelsummary() table objects
  (including the two from Part 3) were built with
  output = "modelsummary_list", which dumps raw R list output instead of a
  formatted table when printed in a Quarto chunk -- confirmed by rendering
  to HTML and finding literal R console text where a table should be.
  Fixed by removing that argument (modelsummary auto-detects the right
  format per output type when left unset). Re-rendered and confirmed the
  table now renders correctly. Wired the figures/table into
  info-agendas.qmd's Data and Measures / Results sections (replacing the
  user's placeholder instruction lines with actual code chunks) and
  test-rendered all three required formats -- html, docx, and pdf -- clean,
  no errors. Added _output/ and _freeze/ to .gitignore (Quarto build
  artifacts, weren't excluded before).
- Same session, later still: asked to redo the VAR truncated to 2005, like
  Liu et al.'s original window. Added Part 4b to analysis.R: same two
  equations, same lag structure, `liu` data subset to year <= 2005
  (n=29 after the lag). Note: Liu et al.'s window is 1969-2005; this data
  starts at 1976 (the earliest year ProQuest has any climate-hearing hit),
  so it's 1976-2005, not an exact match -- documented inline and in the
  table caption. Result reproduces Liu's core qualitative findings
  reasonably well on this closer-matched window: strong attention inertia
  in Congress (CA_lag, p=.021, matching their attention-inertia finding),
  IFE(t-1) significant in the congressional equation (p<.001, matching
  "Congress responds to the previous year's event"), IFE(t) significant in
  the media equation (p=.045, matching "media responds immediately").
  Added m_liu_media_2005/m_liu_congress_2005 and tbl_liu_var_2005 (second
  Results table, cf.-captioned against Liu et al. 2011's own window) to
  info-agendas.qmd. Re-rendered all three formats -- html, docx, pdf --
  clean, no errors.
- Same session, later still: wrote a ProQuest witness-collection prompt for
  the Chrome extension covering all 24 hearings in witnesses_not_located.csv,
  split into three groups by how much was already known: 2 pre-1980
  hearings with known ProQuest HearingIDs, 5 2023-2024 hearings likewise
  already ID'd, and 17 2017-2022 hearings needing a title/date/committee
  search. User ran it: **all 24 found in ProQuest, zero misses.**
  **Flagged for review, not resolved:** H68-20240319-242939 (a House Rules
  Committee hearing on a package of energy/climate bills, incl. repealing
  the Greenhouse Gas Reduction Fund) was coded 'y'/core-title correctly --
  its title genuinely names climate legislation, unlike the Member Day false
  positives -- but its "witnesses" are Members of Congress testifying on
  their own bills, and ProQuest notes it's unlikely to ever be published by
  GPO because it wasn't open to the public. Closer in kind to a markup than
  a hearing; left in the DV pending the user's call, not excluded unilaterally.
  Transcribed the report into proquest_witness_data.py and wrote
  add_proquest_witnesses.py (reuses fetch_new_witnesses.py's classify()
  logic). First pass ran high on 'other' (56%) -- spot-checking found real,
  fixable gaps: "Univ." abbreviations weren't matching the university
  pattern, "Rep" (bare, not "Hon.") for the H68 Members wasn't matching the
  congress pattern, several federal agencies (NSF, CFTC, WMO) and state
  agencies (Attorney General, Air Resources Board, Public Power District,
  Department of Environment variants) had no pattern at all, "Department of
  State" required a U.S. prefix that these older records didn't have, and a
  few known env-groups (Nature Conservancy, WE ACT, Moms Clean Air Force)
  weren't in the list. Fixed all of these in fetch_new_witnesses.py's
  shared classifier (affects future runs too, not just this batch); 'other'
  dropped to 28% (37/131) after.
  **Caught and fixed a real bug of my own**: re-ran the merge script twice
  without restoring from backup first, appending the same 131 rows onto an
  already-131-appended file (would have silently duplicated all 24
  hearings' witnesses). Caught it from the row-count arithmetic not adding
  up, restored from backup, and added an idempotency guard to
  add_proquest_witnesses.py (aborts if any target hearing ID is already
  present) so this can't happen again. Final clean merge: gccWitnesses.csv
  3978 -> 4109 rows (663 unique hearings), verified in R that all 24 new
  hearing IDs are present with no duplicates. witnesses_not_located.csv is
  now empty (header only, both copies) -- nothing left outstanding from
  that list.
- Same session, later still: user decided to exclude H68-20240319-242939.
  Same treatment as the earlier Member Day fixes: set cls='n' in
  proquest_2023_2024_screened.csv with the reasoning on record (Rules
  Committee bill-package hearing, Members testifying on their own bills,
  not open to the public per ProQuest). **2024: 13 -> 12**; updated
  dv_series_1976_2024.csv (both copies) and removed its 8 witness rows from
  gccWitnesses.csv, gccWitnesses_additions.csv, and
  proquest_witnesses_additions.csv, all backed up first. Re-ran
  analysis.R and re-rendered the manuscript (html) to confirm everything
  still sources/renders cleanly -- it does; the one-hearing change barely
  moves the VAR coefficients (e.g. CA_lag -0.257 -> -0.254) and doesn't
  touch the 1976-2005 comparison window at all (2024 isn't in it).
- Same session, later still (2026-09-12): the final piece -- filling
  `hearing-transcripts/` gaps from ProQuest. Discussed download-then-convert
  vs. asking the extension to convert in-browser; recommended download PDFs
  and reuse the already-validated pypdf pipeline, to keep one consistent
  extraction method across the whole corpus rather than mixing in whatever
  ProQuest's own text export produces. Pulled the 149-hearing gap list from
  `transcripts_not_found.csv`, split into 131 known-ProQuest-ID + 17
  needing a title/date search (excluding H68, already excluded from the DV),
  and wrote the Chrome extension prompt.
  **Round 1:** all 148 claimed found, but only 119/145 PDFs actually landed
  on disk -- 26 were missing despite the log saying "downloaded" (a stale
  first-run detection issue), concentrated in the earliest hearings
  (1976-1993), matching the user's own suspicion. Re-download prompt sent
  for those 26.
  **Round 2 (re-download):** log said 26/26 succeeded, but converting them
  surfaced a second, different failure: 25 of the 26 "PDFs" were actually
  the HTML shell of ProQuest's own in-browser PDF.js viewer
  (`<!DOCTYPE html...Congressional PDF Viewer`), not the real PDF -- the
  extension's download-link click was grabbing the viewer page's URL
  instead of the underlying PDF resource for this specific set of
  older/larger documents. Wrote a diagnostic fix-prompt naming the exact
  byte-level symptom (`<!DOCTYPE` vs `%PDF-`) and asking the extension to
  use the viewer's own in-page download control instead.
  **Round 3 (fix):** extension fetched the viewer's real document URL
  directly and confirmed `%PDF-1.4` magic bytes on all 25 before
  downloading -- but flagged (correctly) that it has no filesystem access
  to verify landing/naming. On inspection: exactly as it warned, the 25
  broken originals were still present under the correct names, and the 25
  real PDFs had landed with Chrome's auto `(1)` suffix instead of
  overwriting. Fixed directly (I have local filesystem access): deleted the
  25 broken HTML-shell files, renamed the `(1)` files into place, and found
  and removed one more stray duplicate (`hrg-1980-nar-0012_from_1_to_343.pdf`,
  a leftover partial-range artifact from the extension's own
  troubleshooting, byte-identical to the real file).
  **Conversion:** ran the pypdf pipeline on all 145 -- 120 clean on the
  first pass, the 25 fixed ones clean on the second (size range 88K-3.3M
  characters, all healthy). **Caught a bug in my own conversion script**:
  it re-appended manifest rows for already-converted files on the second
  run instead of skipping them, ballooning `transcript_manifest.csv` to 926
  rows (693 unique) -- rebuilt it cleanly from the actual files on disk
  (one row per real file) rather than trust the append log.
  **Also caught**: the 17 Group B hearings (title-search, no pre-known ID)
  were fully converted and correct, but still showed as "not found" in my
  tracking, because the extension (correctly) found different real
  ProQuest IDs than my placeholder guesses and my script's not-found
  rebuild only matched on the original placeholder -- a bookkeeping miss,
  not a data gap. Verified all 17 `.txt` files exist and are healthy, then
  corrected `transcripts_not_found.csv` down to just the 2 hearings that
  are genuinely citation-only records with no PDF ever produced
  (H36-20160706-01, H36-20231114-239131).
  **Final state: 657 unique hearing transcripts** (509 GovInfo + 145
  ProQuest + 3 pre-existing), verified against disk, not just logs, at
  every step. 2 hearings remain genuinely without a transcript (citation-only
  records, no full text exists anywhere).
- Same session, later still: added two Data and Measures paragraphs to
  info-agendas.qmd (DV collection, IV collection), matched to
  nowlin-style-profile.md, citing `nowlinEnvironmentalPolicymakingEra2019`
  (found in the master bib) alongside `liuExplainingMediaCongressional2011`.
  Re-rendered to confirm both citations resolve.
- **Close-out.** Rewrote README.md, which had drifted significantly out of
  date over the session -- it still claimed `_output/` was tracked in git
  (it's now gitignored, changed this session), didn't mention any of the
  new `data/` files (dv_series, the six iv_*.csv files, transcripts_not_found,
  witnesses_not_located), and described `analysis.R` as only reproducing
  Nowlin (2019) Table 5.1 when it now has five parts culminating in the
  Liu et al. VAR replication that actually feeds the manuscript. Updated
  the Layout, Reproducing, Data, and Notes sections to match current
  reality.
  **Session summary:** started from "find the independent variables," ended
  with all seven Table 5.1 variables extended to 1976-2024 (two spliced, two
  refreshed on today's sources with the scale-change caveat documented, two
  reverse-engineered/reconstructed, one automatic), the DV reconciled through
  three rounds of false-positive hunting (Member Day x2, a Rules Committee
  markup), a full Liu et al. (2011) two-equation VAR replication (not just
  Nowlin's simplification) on both the full series and a window comparable
  to Liu's original, a complete 657-hearing transcript corpus assembled
  across two sources and survived three rounds of silent download failures
  before landing clean, and 441 new witness rows added and categorized.
  Every fix in this log was caught by checking ground truth (disk state, a
  fresh render, a recomputed ratio) rather than trusting an intermediate
  report at face value -- worth keeping up given how often that's what
  actually caught the problem.

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

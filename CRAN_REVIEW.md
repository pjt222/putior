# CRAN-Readiness Review — putior 0.2.0

**Type of submission:** UPDATE to the version already on CRAN (0.1.0, published 2025-06-19). This is **not** a new submission. CRAN may run reverse-dependency checks; cran-comments must declare the package as an update.

**Reviewer:** Lead reviewer (static review synthesis) + main-loop empirical reconciliation
**Date:** 2026-05-31
**Adversarial verdicts received:** none (empty array) — the verify gate only fired on `cran_blocking=true` findings and there were none. Substituted by (a) a real `R CMD check --as-cran` run and (b) main-loop empirical reproduction of the top findings (see below).

---

## STATUS: FIXES APPLIED (2026-05-31)

Required + all quality fixes applied and re-verified by a full `R CMD check --as-cran`
(structurally clean: codoc OK, examples/tests/vignettes/non-ASCII/top-level all OK; only
the local-LaTeX `pdflatex` artifact remains). Done:

- ✅ **cran-comments.md** rewritten as an update from 0.1.0 (0 reverse deps; no "New submission").
- ✅ **mermaid-01** fixed in `R/put_diagram.R` (`resolve_label(suffix=)`) — real output now
  `["label<br/>(file)"]`, re-validated `valid:true` by the Mermaid engine. roxygen + `.Rd` updated.
- ✅ **NEWS.md:131** "skills reference" → "AI integration".
- ✅ **test-04** clipboard test now mocks `clipr::write_clip` and asserts (no longer silently empty);
  added a **mermaid-01 regression test**.
- ✅ **acp-03/rsrc-03** ACP port-range validation with `suppressWarnings(as.integer())`.
- ✅ **mcp-03** `putior_guide` tool description corrected (real default is `console`).
- ✅ `.Rbuildignore` now excludes `CRAN_REVIEW.md`, `.cran_check_ground_truth.md`, `.gitattributes`.

**Remaining to submit:** (1) run win-builder (renders the PDF manual + remote incoming checks),
paste results into cran-comments.md; (2) submit via `devtools::release()`. TIER 3 items deferred.

---

## EMPIRICAL ADDENDUM (supersedes static guesses)

A real `R CMD check --as-cran` was run on a freshly-built isolated `putior_0.2.0.tar.gz`
(R 4.5.2, all Suggests installed incl. mcptools from CRAN). **Result: structurally clean.**

```
checking examples ... OK
checking tests ... Running 'testthat.R' [104s] OK
checking re-building of vignette outputs ... [35s] OK
checking Rd files / metadata / line widths / cross-references / \usage / contents ... OK
checking code files for non-ASCII characters ... OK      <-- INVALIDATES rsrc-01
checking R code for possible problems ... OK
checking dependencies in R code ... OK
```

The only ERROR/WARNING/NOTE were all a single local cause — **`pdflatex is not available`**
(no LaTeX in this WSL R; CRAN renders the PDF manual itself). Not package defects.

**Three findings reconciled against hard evidence:**
- **rsrc-01 (em-dashes) — INVALIDATED.** The 4 U+2014 chars exist, but `Encoding: UTF-8`
  is declared, so the check prints `checking code files for non-ASCII characters ... OK`.
  They cause **no NOTE**. The static reviewer confirmed the chars exist but never ran the
  check to confirm they *cause* a NOTE — they don't. Downgraded to cosmetic (TIER 3).
- **mermaid-01 — CONFIRMED by the actual Mermaid parser.** Current output
  `load["Load Data"<br/>(file.R)]` → `valid:false, Parse error ... got 'PS'`. Proposed fix
  `load["Load Data<br/>(file.R)"]` → `valid:true`, renders. Real bug; not a CRAN blocker.
- **Reverse dependencies: 0.** `tools::package_dependencies("putior", reverse=TRUE)` →
  `character(0)`. cran-comments can state "There are no reverse dependencies."

**Two CRAN steps the local run could NOT cover (close via win-builder):**
1. PDF manual LaTeX rendering (no local pdflatex). Rd *syntax* checks all passed, so risk is low.
2. Remote incoming checks (`_R_CHECK_CRAN_INCOMING_REMOTE_=FALSE`): URL liveness vs CRAN,
   version-vs-CRAN, update-vs-new-submission detection.

**Reframed verdict:** check-clean locally; **submittable after the cran-comments fix + one
clean win-builder run** (the standard final gate for an update; it renders the manual AND
runs remote incoming). NOT "YES" on the local check alone.

---

## Executive Summary — Verdict

**putior 0.2.0 is submittable from a static-review standpoint.** There are **zero confirmed CRAN acceptance blockers** (TIER 1 is empty). Every finding in the corpus is `cran_blocking = false`, and the adversarial verdicts array is empty.

**Critical path before pressing submit:**
1. Fix the small set of TIER 2 action items (all cheap, all under ~30 min total).
2. **Reconcile this static review against the independently-running `R CMD check --as-cran`.** The single most plausible delta is a *new* "non-ASCII characters in R files" NOTE from the 4 em-dashes (rsrc-01) — fix it preemptively.
3. Rewrite `cran-comments.md` so it states the truth: an update from 0.1.0, not a "New submission."

The package is otherwise in strong shape: 24 exports all documented with `\value`, all internal helpers carry `\keyword{internal}`, `pkgdown::check_pkgdown()` passes, all server/interactive examples are correctly `\dontrun{}`, all test I/O is confined to `tempdir()`, no network calls, global state is restored via `on.exit`.

**Tier counts:** TIER 1 (blockers) = **0** · TIER 2 (fix before submit) = **7** · TIER 3 (enhancements, post-submit ok) = **8** · Verified-clean / no-action = **~20**.

---

## Re-verification (lead reviewer independently confirmed the top findings)

| Finding | How verified | Result |
|---|---|---|
| mermaid-01 | Ran `put_diagram(wf, show_source_info=TRUE, output="raw")` under R 4.5.2 | **Reproduced.** Output node: `diagram_gen["Generate Mermaid Diagram"<br/>(put_diagram.R)]` — the `<br/>(...)` sits OUTSIDE the closing quote, malformed Mermaid. Confirmed real bug. |
| rsrc-01 | `LC_ALL=C grep -nP '[^\x00-\x7F]' R/*.R` | **Confirmed.** 4 em-dashes (U+2014) at put_auto.R:95, put_auto.R:251, putior.R:145, putior.R:378 — all in comments. |
| cran-01 | Read `cran-comments.md` | **Confirmed.** Lines 5-7 + 12-13 say "New submission"; line 26 says "This is an update from version 0.1.0 to 0.2.0." Self-contradictory. |
| cran-04 | Read `NEWS.md:130-131` | **Confirmed.** Line 131 lists "skills reference" vignette; line 8-9 of same file documents rename to `ai-integration.Rmd`; no skills vignette on disk. |
| show_source_info default | Read `put_diagram.R:127` | **Confirmed FALSE.** Bug is opt-in, not default-path. |

---

## TIER 1 — BLOCKERS (must fix before submit)

**None.**

There is no confirmed finding that would cause an R CMD check ERROR/WARNING, a CRAN policy violation, or an auto-reject. Every finding is `cran_blocking = false` and no adversarial verdict refuted that classification. Do not manufacture a blocker to fill this tier. The remaining work is NOTE-level cleanup and quality.

---

## TIER 2 — NOTES / reviewer nits (should fix before submit)

### ~~T2-1 · rsrc-01 — Non-ASCII em-dash (U+2014) in 4 R source comments~~  *(INVALIDATED → moved to TIER 3 cosmetic)*
- **STATUS: NOT a NOTE.** The live `R CMD check --as-cran` printed `checking code files for
  non-ASCII characters ... OK`. Because `DESCRIPTION` declares `Encoding: UTF-8`, valid UTF-8
  em-dashes in comments are accepted and produce no NOTE. The static reviewer's claim that this
  would surface a *new* NOTE was wrong — confirmed exists, but does not cause a check finding.
- **file:line:** `R/put_auto.R:95,251`, `R/putior.R:145,378` (4× U+2014, all in comments)
- **Optional cosmetic fix:** replace `—` → `--` for pure-ASCII source hygiene. Zero CRAN impact,
  not required, do last if at all.

### T2-2 · cran-01 — `cran-comments.md` claims "New submission" but 0.2.0 is an UPDATE
- **file:line:** `cran-comments.md:5-7, 12-13, 26`
- **Evidence:** Lines 5-7 report incoming-feasibility NOTE as "New submission."; lines 12-13 say win-builder returned "1 note (new submission)"; line 26 contradicts: "This is an update from version 0.1.0 to 0.2.0." An update will **not** receive a "New submission" NOTE. Win-builder dates (2026-03-10, 2026-02-13) are stale.
- **Fix:** Rewrite to state plainly it is an update from 0.1.0 (already on CRAN). Remove the "New submission" framing. Add reverse-dependency status (e.g., "There are no reverse dependencies." if true). Re-run win-builder/R-hub for 0.2.0 and paste current dates/URLs, or drop stale ones.

### T2-3 · mermaid-01 — `show_source_info=TRUE` (inline) emits invalid Mermaid that breaks the whole diagram
- **file:line:** `R/put_diagram.R:582` (append) + `R/put_diagram.R:664` (quote close in `sanitize_mermaid_label`)
- **Evidence (reproduced):** `resolve_label()` → `sanitize_mermaid_label()` closes the quote at line 664 (`paste0('"', label, '"')`); then line 582 appends OUTSIDE that quote: `paste0(label_text, "<br/>(", node$file_name, ")")`. Empirically produces `diagram_gen["Generate Mermaid Diagram"<br/>(put_diagram.R)]`, which a Mermaid parser rejects — and a parse error aborts the **entire** diagram, not just the node. Filename is also interpolated unescaped. Same renderer-breakage class as the previously-fixed #32/#33.
- **Not a CRAN blocker because:** opt-in (`show_source_info` defaults to `FALSE`, `put_diagram.R:127`); runtime output correctness only — produces no R CMD check ERROR/WARNING/NOTE.
- **Adversarial verdict:** none received; lead reviewer reproduced the bug under R 4.5.2 (exit 0, malformed string confirmed). Classification stands: real bug, not a CRAN blocker.
- **Fix:** Build the raw label first: `raw_label <- paste0(label, "<br/>(", file_name, ")")`, THEN pass once through `sanitize_mermaid_label()` so the suffix and filename land **inside** the quotes and the filename is escaped. Decide whether `<br/>` should survive sanitization (add a carve-out if so). Add a regression test asserting `show_source_info=TRUE` output contains no unquoted `"<br/>`.

### T2-4 · cran-04 — NEWS.md lists a nonexistent "skills reference" vignette  *(factual error in a shipped file)*
- **file:line:** `NEWS.md:130-131`
- **Evidence:** Line 131 names the 8th vignette "skills reference"; the same file's lines 8-9 document the rename `skills.Rmd` → `ai-integration.Rmd`; `vignettes/` contains `ai-integration.Rmd` and no skills vignette.
- **Note:** Originally tagged ENHANCEMENT; lifted to TIER 2 because NEWS.md ships in the tarball and this is a one-word factual error.
- **Fix:** `NEWS.md:131` — replace "skills reference" with "AI integration".

### T2-5 · test-04 — Clipboard test asserts nothing when clipr is installed (clipr now on CRAN)
- **file:line:** `tests/testthat/test-put_diagram.R:266-283`
- **Evidence:** Line 270 wraps the only assertions in `if (!requireNamespace("clipr", quietly = TRUE))`. clipr is now on CRAN, so the `test_that` block runs **zero expectations** (testthat reports an empty test). The clipboard-success path is never exercised.
- **Fix:** Add an else/sibling test with `skip_if_not_installed("clipr")` that asserts `put_diagram(workflow, output="clipboard")` writes to the clipboard (or `local_mocked_bindings()` on `clipr::write_clip`). At minimum add an explicit expectation so the test is not silently empty.

### T2-6 · acp-03 — `putior_acp_server()` does not validate port range (MCP does)
- **file:line:** `R/acp.R:587, 631`
- **Evidence:** `api_run(..., port = as.integer(port))` (line 631) with no range check, whereas `putior_mcp_server` validates 1–65535 (`mcp.R:108-114`). Inconsistent and allows nonsense ports through to the server layer.
- **Fix:** Mirror MCP validation in `putior_acp_server` — reject NA/<1/>65535 with a helpful `stop()`. (Wrap coercion in `suppressWarnings(as.integer(port))` per rsrc-03.)

### T2-7 · mcp-03 — `putior_guide` MCP tool description claims a default it never sets
- **file:line:** `R/mcp.R:643-647`
- **Evidence:** `output` arg description says "(default: raw for MCP)" (line 644) but only `required=FALSE` is set — the value falls through to `putior_guide`'s `match.arg` default of "console" (`putior_guide.R:30-32`), not "raw". Misleading to the calling agent.
- **Fix:** Either drop "(default: raw for MCP)" from the description, or wrap `fun` in a closure that defaults `output="raw"`.

---

## TIER 3 — ENHANCEMENTS (post-submit ok)

### T3-1 · doc-03 — Core scan/diagram examples are all `\dontrun{}` despite shippable runnable fixtures
- **file:line:** `man/put.Rd`, `man/put_auto.Rd`, `man/put_diagram.Rd:113`, `man/put_generate.Rd`, `man/put_merge.Rd`
- **Evidence:** All five wrap full `\examples` in `\dontrun{}` using fictional paths (`put("./src/")`), yet the package ships real annotated files in `inst/examples/`; `put_theme.Rd` already has a runnable example.
- **Fix (optional):** Convert `put()` / `put_diagram()` examples to runnable form via `system.file("examples", package="putior")` or a `tempdir()` fixture, wrapping slow/IO parts in `\donttest{}`. Keep `\dontrun{}` only for truly non-runnable cases (servers, `put_generate(insert=TRUE)`).

### T3-2 · rsrc-02 — Enum params use manual `%in%` checks instead of `match.arg()`
- **file:line:** `R/put_diagram.R:182, 208, 221`; `R/put_auto.R:217, 231, 372`
- **Evidence:** `if (!theme %in% .VALID_THEMES)` etc.; if a length>1 vector is passed, R 4.3+ raises "condition has length > 1". `put_diagram.R:139` already uses `match.arg()` for `direction`.
- **Fix (optional):** Convert scalar-enum validations to `match.arg()` for consistency and length>1 safety.

### T3-3 · rsrc-03 — `as.integer(port)` on user input emits a spurious coercion warning
- **file:line:** `R/mcp.R:109` (also `acp.R:631`, `mcp.R:124`)
- **Evidence:** Non-numeric port fires "NAs introduced by coercion" before the clean validation `stop()`. NA is correctly caught; the warning is just noise.
- **Fix (optional):** `port <- suppressWarnings(as.integer(port))`. Pairs naturally with T2-6.

### T3-4 · mcp-02 — MCP http transport lacks the 0.0.0.0 warning ACP has
- **file:line:** `R/mcp.R:83-85, 120-125` (vs `acp.R:599-605`)
- **Fix (optional):** Add the same 0.0.0.0 warning guard to `putior_mcp_server` http transport.

### T3-5 · mermaid-02 — No accessibility directives (`accTitle`/`accDescr`) emitted
- **file:line:** `R/put_diagram.R:253-261`
- **Evidence:** No `accTitle`/`accDescr`/`aria` anywhere in `R/`. Package markets 4 colorblind-safe themes but emits no machine-readable accessible title/description. `accTitle`/`accDescr` shipped in Mermaid v9.0.0 (2022) — safe under the pinned 12.1.0 (since 2026-10-12, #48) and on GitHub.
- **Fix (optional, additive):** When `title` is supplied, also emit `accTitle: <title>` and an `accDescr:` after the `flowchart <direction>` line. Optional `acc_descr` param.

### T3-6 · mermaid-03 — Confirmation: v11.3+ `A@{ shape: ... }` syntax correctly NOT used (keep it that way)
- **file:line:** `R/put_diagram.R:598-626`
- **Evidence:** `get_node_shape()` uses only classic ASCII shapes. The expanded shape catalog requires Mermaid v11.3.0+. The pkgdown site and sandbox now pin `mermaid@12.1.0` (2026-10-12, #48), but Quarto bundles Mermaid 11.12.0, so the floor that matters is the oldest renderer users have (#50).
- **Action:** Superseded: the site no longer constrains this. Decide in #50 against the renderer matrix (Quarto 11.12.0 is the oldest), and verify GitHub rendering first. No-op now.

### T3-7 · pkgdown-04 — Redundant Mermaid double-render timers + duplicate `extra.css` @import
- **file:line:** `_pkgdown.yml:133-138` (timers), `_pkgdown.yml:153` (@import)
- **Fix (optional, cosmetic):** Drop the line-138 fallback timer (guard with a "rendered" flag); remove the `@import` since pkgdown auto-links `extra.css`.

### T3-8 · pkgdown-05 — No `redirects:` entry for the renamed skills→ai-integration article
- **file:line:** `_pkgdown.yml` (absent)
- **Evidence:** In-repo links are clean, but external 0.1.0-era links to `articles/skills.html` will 404 on the live site.
- **Fix (optional):** Add `redirects:` mapping `articles/skills.html` → `articles/ai-integration.html`.

---

## Verified clean / no action required (≈20 confirmations)

These were checked and **pass** — listed for traceability so the action plan is not polluted with non-actions. Do **not** treat any of these as work items.

**CRAN metadata & build**
- **cran-06** — Authors@R/ORCID/Maintainer correct; Title is proper title-case <65 chars; Description prose style compliant (single-quotes 'PUT'/'Mermaid', valid DOIs); License field matches LICENSE. (`DESCRIPTION:2,4-6,7-18,21-22`)
- **cran-02** — `CRAN-SUBMISSION-CHECKLIST.md` is badly stale BUT excluded by `.Rbuildignore:19`; does not ship. (dev-hygiene only)
- **cran-03** — `.gitattributes` not matched by `.Rbuildignore` BUT auto-excluded by R CMD build's built-in hidden-file list; produces no NOTE. (optional belt-and-suspenders: add `^\.gitattributes$`)
- **cran-05** — LICENSE YEAR is 2024 (release is 2026); cosmetic, CRAN does not reject on year. (optional: `2024-2026`)

**Policy**
- **policy-01** — All blocking-server / interactive examples correctly `\dontrun{}`; zero `\donttest` in package.
- **policy-02** — Log-level option mutation always restored via `on.exit` (5 call sites + `.onLoad` guard).
- **policy-03** — Vignette file-writing code is non-executed (`eval=FALSE` or display fences); sole eval=TRUE write uses `tempfile()`.
- **policy-04** — All testthat file writes use `tempdir()`/`tempfile()` with `on.exit(unlink())`.

**Documentation**
- **doc-01** — All 24 exports have meaningful `\value{}`.
- **doc-02** — All formals documented for all spot-checked functions; no `\usage`/`\arguments` mismatch.
- **doc-04** — S3 print/summary methods lack `\examples` (acceptable; exercised via parent class).
- **doc-05** — All 61 internal helper `.Rd` carry `\keyword{internal}`; reference index clean.
- **doc-06** — All exports have non-empty `\title`/`\description`.

**Tests**
- **test-01** — Server functions inspected via `body()`/`formals()`, never invoked (no port bind). CRAN-safe.
- **test-02** — Optional-dependency skips correctly applied (ellmer, uuid, logger).
- **test-03** — All writes confined to `tempdir()`; no network.
- **test-05** — Deprecated `info=` arg on basic expectations (3 sites; works, minor nit only).
- **test-06** — `putior.log_level` mutated without `withr`-scoped restore (robustness nit; ENHANCEMENT).
- **test-07** — Edition-3 idioms clean; full export coverage in tests.

**pkgdown / MCP / ACP**
- **pkgdown-01** — `pkgdown::check_pkgdown()` returns "No problems found"; index complete.
- **pkgdown-02** — All 8 vignettes listed; all navbar hrefs resolve; no dangling skills links.
- **pkgdown-03** — URL consistent with DESCRIPTION; dev-mode disabled; dark-mode Mermaid re-render JS correct.
- **mcp-01** — MCP graceful degradation, ellmer formals-match, `\dontrun` examples all correct.
- **acp-01** — ACP path sanitization (control-char + traversal rejection), 0.0.0.0 warning, LRU eviction all verified.
- **acp-02** — `sanitize_acp_path` allows absolute paths by design (tested); not a defect.

---

## Rejected by verification

**None.** The adversarial verdicts array was empty — no finding was refuted. As partial substitute, the lead reviewer independently re-verified the five highest-impact findings (mermaid-01 reproduced under R 4.5.2; em-dashes, cran-comments contradiction, NEWS.md "skills reference", and the `show_source_info=FALSE` default all confirmed by direct file read). No finding was downgraded or removed.

---

## ACTION PLAN (ordered)

**The ONLY item required for CRAN acceptance is #1 (cran-comments). Everything else is discretionary quality.**

1. **cran-01 (REQUIRED) — Rewrite `cran-comments.md`** as an update from 0.1.0: drop the "New submission" framing (lines 5-7, 12-13), state "There are no reverse dependencies." (verified: 0), refresh or remove the stale 2026-02/03 win-builder/R-hub dates/URLs.
2. **Run win-builder** (`devtools::check_win_devel()`) — the standard final gate for an update. Renders the PDF manual (untestable locally, no LaTeX) AND runs the remote incoming checks this local run skipped. Submit only after it returns clean.
3. **mermaid-01 (quality) — Fix `show_source_info` inline bug** in `R/put_diagram.R:582`: build `paste0(label, "<br/>(", file, ")")` BEFORE `sanitize_mermaid_label` so `<br/>` lands inside the quotes — BUT verify the sanitizer doesn't HTML-escape `<br/>` into `&lt;br/&gt;` (it strips `\r\n` and escapes `"`/`|`; may need a `<br/>` carve-out). After editing, re-run `put_diagram` and feed the REAL output through the Mermaid validator; also check `source_info_style="subgraph"`. Add a regression test.
4. **cran-04 (quality) — Fix `NEWS.md:131`** "skills reference" → "AI integration" (factual error in shipped file).
5. **test-04 (quality) — Add a real clipr assertion** (`skip_if_not_installed("clipr")`) so the clipboard test is not silently empty now that clipr is on CRAN.
6. **acp-03 + rsrc-03 (quality) — Port-range validation** in `putior_acp_server` with `suppressWarnings(as.integer())`, mirroring MCP.
7. **mcp-03 (quality) — Fix `putior_guide` tool description** (drop false "default: raw" or set the default).
8. **rsrc-01 + TIER 3 (cosmetic/optional)** — em-dashes (no CRAN impact), accessibility directives, redirects, etc. Defer.

---

## Reconciliation note — live `R CMD check --as-cran`

The live `R CMD check --as-cran` **was run** (see EMPIRICAL ADDENDUM at top). Reconciliation complete:

- **Result: structurally clean** — examples/tests/vignettes/all Rd checks/R code/dependencies all OK. The only ERROR/WARNING/NOTE = local `pdflatex is not available` (CRAN renders the manual itself).
- **rsrc-01 disproved:** `checking code files for non-ASCII characters ... OK`. The predicted "second NOTE" did NOT appear — em-dashes are harmless under `Encoding: UTF-8`. Downgraded to cosmetic.
- **Still pending (local run could not test):** PDF-manual LaTeX rendering and the remote incoming checks (version-vs-CRAN, URL liveness, update detection). **Both are covered by a win-builder run — do that before submit.** Optional local certainty on the manual: `tinytex::install_tinytex()` then re-check (installs a LaTeX distro — a system change; ask first).
- No new ERROR/WARNING surfaced outside this report's corpus.

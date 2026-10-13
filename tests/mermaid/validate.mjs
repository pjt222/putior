// Parse and render every diagram in putior's Mermaid corpus in headless
// Chromium, on every Mermaid version listed in package.json, with Mermaid's
// defaults and with the configuration the pkgdown site and the sandbox use.
//
//   Rscript tests/mermaid/generate-corpus.R tests/mermaid/corpus   # from the repo root
//   node tests/mermaid/validate.mjs tests/mermaid/corpus
//
// A case fails when generating it raised an R error, when Mermaid cannot
// parse or render it, when the rendered SVG has fewer nodes than Mermaid
// parsed (Mermaid 12 drops some nodes without an error), or when Mermaid's
// nodes differ from the node ids putior defined (phantom nodes created by an
// edge to an id that was never defined, or two definitions of one id).
//
// Cases in expected-failures.json are known bugs: they are reported but do
// not fail the run. A listed case that passes does fail the run, so the list
// is kept up to date as the bugs are fixed.

import { chromium } from 'playwright-core';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const harnessDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(harnessDir, '..', '..');
const corpusDir = path.resolve(process.argv[2] ?? path.join(harnessDir, 'corpus'));

const readJson = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

// Every dependency that is an alias of mermaid, e.g. "mermaid-12.1.0": "npm:mermaid@12.1.0"
const mermaidVersions = Object.entries(readJson(path.join(harnessDir, 'package.json')).dependencies)
  .filter(([, spec]) => spec.startsWith('npm:mermaid@'))
  .map(([alias]) => ({
    alias,
    version: readJson(path.join(harnessDir, 'node_modules', alias, 'package.json')).version,
    script: path.join(harnessDir, 'node_modules', alias, 'dist', 'mermaid.min.js'),
  }));

// The site and the sandbox pin a Mermaid version; it must be one of the tested ones.
const pinnedFiles = ['_pkgdown.yml', 'inst/shiny/putior-sandbox/app.R'];
const setupProblems = [];
for (const pinnedFile of pinnedFiles) {
  const text = fs.readFileSync(path.join(repoRoot, pinnedFile), 'utf8');
  for (const match of text.matchAll(/mermaid@(\d+\.\d+\.\d+)/g)) {
    if (!mermaidVersions.some((entry) => entry.version === match[1])) {
      setupProblems.push(`${pinnedFile} pins mermaid@${match[1]}, which package.json does not test`);
    }
  }
}

// Mermaid's own defaults, and the configuration of the pkgdown site
// (_pkgdown.yml) and the sandbox (inst/shiny/putior-sandbox/app.R).
const mermaidConfigs = {
  default: { startOnLoad: false, securityLevel: 'strict' },
  site: {
    startOnLoad: false,
    securityLevel: 'strict',
    layout: 'dagre',
    look: 'classic',
    theme: 'default',
    flowchart: { htmlLabels: true, curve: 'linear', wrappingWidth: 200, minNodeWidth: 0 },
  },
};

const manifest = readJson(path.join(corpusDir, 'manifest.json'));
const expectedFailures = readJson(path.join(harnessDir, 'expected-failures.json'));

for (const caseName of Object.keys(expectedFailures)) {
  if (!manifest.some((entry) => entry.name === caseName)) {
    setupProblems.push(`expected-failures.json lists "${caseName}", which is not in the corpus`);
  }
}

// Runs in the page: parse, collect Mermaid's nodes, render, inspect the SVG.
async function checkInPage(code) {
  // One line per error: Mermaid's parse errors end with "Expecting ...,
  // got 'end'", and frontmatter (YAML) errors quote the line as " 1 | title: ...".
  const firstLine = (error) => {
    const lines = String(error?.message ?? error).split('\n').filter((line) => line.trim() !== '');
    const unexpectedToken = (lines[lines.length - 1] ?? '').match(/got '[^']*'$/);
    if (lines.length > 1 && unexpectedToken) return `${lines[0]} ${unexpectedToken[0]}`;
    const sourceLine = lines.find((line) => /^\s*\d+ \|/.test(line));
    if (sourceLine) return `${lines[0]} in "${sourceLine.trim()}"`;
    return (lines[0] ?? '').slice(0, 300);
  };
  const result = { problems: [], vertexIds: null };
  try {
    await mermaid.parse(code);
  } catch (error) {
    result.problems.push(`parse: ${firstLine(error)}`);
    return result;
  }
  const diagram = await mermaid.mermaidAPI.getDiagramFromText(code);
  const vertices = diagram.db.getVertices();
  result.vertexIds = vertices instanceof Map ? [...vertices.keys()] : Object.keys(vertices);
  try {
    window.renderCounter = (window.renderCounter ?? 0) + 1;
    const { svg } = await mermaid.render(`putior-check-${window.renderCounter}`, code);
    // Parse as HTML, the way a page inserts it: labels hold HTML such as <br>,
    // which an XML parser rejects.
    const container = document.createElement('div');
    container.innerHTML = svg;
    const svgRoot = container.querySelector('svg');
    if (svgRoot.getAttribute('aria-roledescription') === 'error') {
      result.problems.push('render: Mermaid drew its error diagram');
    } else if (svg.includes('Maximum text size in diagram exceeded')) {
      result.problems.push('render: text is over maxTextSize, Mermaid drew a placeholder');
    } else {
      const svgNodeCount = svgRoot.querySelectorAll('g.node').length;
      if (svgNodeCount !== result.vertexIds.length) {
        result.problems.push(`render: SVG has ${svgNodeCount} nodes, Mermaid parsed ${result.vertexIds.length}`);
      }
    }
  } catch (error) {
    result.problems.push(`render: ${firstLine(error)}`);
  }
  return result;
}

function compareNodes(entry, vertexIds) {
  const problems = [];
  const definedIds = entry.defined_node_ids;
  const duplicates = [...new Set(definedIds.filter((id, index) => definedIds.indexOf(id) !== index))];
  if (duplicates.length > 0) problems.push(`nodes: defined more than once: ${duplicates.join(', ')}`);
  const subgraphIds = entry.defined_subgraph_ids;
  const duplicateSubgraphs = [...new Set(subgraphIds.filter((id, index) => subgraphIds.indexOf(id) !== index))];
  if (duplicateSubgraphs.length > 0) problems.push(`subgraphs: defined more than once: ${duplicateSubgraphs.join(', ')}`);
  const phantoms = vertexIds.filter((id) => !definedIds.includes(id));
  if (phantoms.length > 0) problems.push(`nodes: used but never defined: ${phantoms.join(', ')}`);
  const missing = definedIds.filter((id) => !vertexIds.includes(id));
  if (missing.length > 0) problems.push(`nodes: defined but not parsed: ${[...new Set(missing)].join(', ')}`);
  return problems;
}

const problemsByCase = new Map(manifest.map((entry) => [entry.name, []]));
for (const entry of manifest) {
  if (entry.error) problemsByCase.get(entry.name).push(`generate: ${entry.error}`);
}

const browser = await chromium.launch();
try {
  for (const mermaidVersion of mermaidVersions) {
    for (const [configName, config] of Object.entries(mermaidConfigs)) {
      const page = await browser.newPage();
      await page.setContent('<!doctype html><html><body></body></html>');
      await page.addScriptTag({ path: mermaidVersion.script });
      await page.evaluate((config) => mermaid.initialize(config), config);
      const label = `${mermaidVersion.version}/${configName}`;
      for (const entry of manifest) {
        if (entry.error) continue;
        const code = fs.readFileSync(path.join(corpusDir, entry.file), 'utf8');
        const result = await page.evaluate(checkInPage, code);
        const problems = [...result.problems];
        if (result.vertexIds) problems.push(...compareNodes(entry, result.vertexIds));
        for (const problem of problems) problemsByCase.get(entry.name).push(`${label} ${problem}`);
      }
      await page.close();
    }
  }
} finally {
  await browser.close();
}

let failureCount = setupProblems.length;
for (const problem of setupProblems) console.log(`SETUP  ${problem}`);
const counts = { PASS: 0, XFAIL: 0, FAIL: 0, XPASS: 0 };
for (const entry of manifest) {
  const problems = problemsByCase.get(entry.name);
  const expected = expectedFailures[entry.name];
  let status;
  if (problems.length === 0) status = expected ? 'XPASS' : 'PASS';
  else status = expected ? 'XFAIL' : 'FAIL';
  counts[status] += 1;
  if (status === 'FAIL' || status === 'XPASS') failureCount += 1;
  console.log(`${status.padEnd(6)} ${entry.name}${expected ? `  (${expected})` : ''}`);
  if (status === 'XPASS') console.log('         passes now: remove it from expected-failures.json');
  // Same problem on several versions/configs: print it once with the list of where.
  const grouped = new Map();
  for (const problem of problems) {
    const [where, ...rest] = problem.startsWith('generate: ') ? ['R', problem] : problem.split(' ');
    const what = rest.join(' ');
    if (!grouped.has(what)) grouped.set(what, []);
    grouped.get(what).push(where);
  }
  for (const [what, wheres] of grouped) console.log(`         ${what}  [${wheres.join(', ')}]`);
}

const versionList = mermaidVersions.map((entry) => entry.version).join(', ');
console.log(`\n${manifest.length} cases on mermaid ${versionList} x ${Object.keys(mermaidConfigs).join('/')}: ` +
  `${counts.PASS} pass, ${counts.XFAIL} known failures, ${counts.FAIL} fail, ${counts.XPASS} unexpectedly pass`);
process.exitCode = failureCount > 0 ? 1 : 0;

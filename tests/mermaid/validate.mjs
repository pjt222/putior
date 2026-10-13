// Parse and render every diagram in putior's Mermaid corpus in headless
// Chromium, on every Mermaid version listed in package.json, with Mermaid's
// defaults and with the configuration the pkgdown site and the sandbox use.
//
//   Rscript tests/mermaid/generate-corpus.R tests/mermaid/corpus   # from the repo root
//   node tests/mermaid/validate.mjs tests/mermaid/corpus
//
// A case fails when generating it raised an R error, when Mermaid cannot
// parse or render it, when the rendered SVG does not draw exactly the nodes
// Mermaid parsed (Mermaid 12 drops some nodes without an error), or when the
// nodes differ from what putior defined: phantom nodes from an edge to an id
// that was never defined, two definitions of one id, fewer nodes than the
// workflow has, or class/click lines aimed at ids that do not exist. It also
// fails when Mermaid parses fewer edges than the diagram has "-->" lines
// (its lexer can swallow a line without an error), and, for a case that
// lists expected_texts, when a label does not show one of them as written
// (Mermaid can cut the end off an entity without an error). When the
// diagram's frontmatter sets a look, every node that carries a data-look
// attribute (Mermaid 11.17.2 and later) must have it.
//
// Cases in expected-failures.json are known bugs. Each entry names its issue
// and the kinds of problem it is known to cause ("generate", "parse",
// "render", "nodes", "edges", "subgraphs", "text", "look"). A listed case
// counts as a known failure only if all its problems are of those kinds; a
// problem of a different kind fails the run (a new problem of a listed kind
// does not). A listed case that passes also fails the run, so the list is
// kept up to date as the bugs are fixed.
//
// MERMAID_EXTRA_ALIASES (comma-separated) adds packages installed in
// node_modules but not listed in package.json, e.g. the scheduled run's
// "mermaid-latest".

import { chromium } from 'playwright-core';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const harnessDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(harnessDir, '..', '..');
const corpusDir = path.resolve(process.argv[2] ?? path.join(harnessDir, 'corpus'));
const caseTimeoutMs = 60_000;

const readJson = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

// Every dependency that is an alias of mermaid, e.g. "mermaid-12.1.0": "npm:mermaid@12.1.0"
const aliases = Object.entries(readJson(path.join(harnessDir, 'package.json')).dependencies)
  .filter(([, spec]) => spec.startsWith('npm:mermaid@'))
  .map(([alias]) => alias);
for (const extraAlias of (process.env.MERMAID_EXTRA_ALIASES ?? '').split(',')) {
  if (extraAlias.trim() !== '') aliases.push(extraAlias.trim());
}
const mermaidVersions = aliases.map((alias) => ({
  alias,
  version: readJson(path.join(harnessDir, 'node_modules', alias, 'package.json')).version,
  script: path.join(harnessDir, 'node_modules', alias, 'dist', 'mermaid.min.js'),
}));

// The site, the sandbox and the scripts that render the cheatsheet images
// and the demo GIF pin a Mermaid version; it must be one of the tested ones.
// Each file must have a pin, or the check would switch itself off.
const pinnedFiles = [
  '_pkgdown.yml',
  'inst/shiny/putior-sandbox/app.R',
  'inst/cheatsheet/generate-diagrams.R',
  'inst/examples/create-demo-gif.R',
];
const setupProblems = [];
for (const pinnedFile of pinnedFiles) {
  const text = fs.readFileSync(path.join(repoRoot, pinnedFile), 'utf8');
  const pins = [...text.matchAll(/mermaid@(\d+\.\d+\.\d+)/g)].map((match) => match[1]);
  if (pins.length === 0) {
    setupProblems.push(`${pinnedFile} has no exact mermaid@x.y.z pin`);
  }
  for (const pin of pins) {
    if (!mermaidVersions.some((entry) => entry.version === pin)) {
      setupProblems.push(`${pinnedFile} pins mermaid@${pin}, which package.json does not test`);
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
const problemKinds = ['generate', 'parse', 'render', 'nodes', 'edges', 'subgraphs', 'text', 'look'];

for (const [caseName, expected] of Object.entries(expectedFailures)) {
  if (!manifest.some((entry) => entry.name === caseName)) {
    setupProblems.push(`expected-failures.json lists "${caseName}", which is not in the corpus`);
  }
  if (!expected.issue || !Array.isArray(expected.problems) ||
      expected.problems.some((kind) => !problemKinds.includes(kind))) {
    setupProblems.push(`expected-failures.json entry "${caseName}" needs an "issue" and "problems" from ${problemKinds.join(', ')}`);
  }
}

// Runs in the page: parse, collect Mermaid's nodes, render, compare the
// nodes drawn in the SVG with the nodes Mermaid parsed.
async function checkInPage(code) {
  // One line per error: Mermaid's parse errors end with "Expecting ...,
  // got 'end'", and frontmatter (YAML) errors quote the line as " 1 | title: ...".
  const summarize = (error) => {
    const lines = String(error?.message ?? error).split('\n').filter((line) => line.trim() !== '');
    const unexpectedToken = (lines[lines.length - 1] ?? '').match(/got '[^']*'$/);
    if (lines.length > 1 && unexpectedToken) return `${lines[0]} ${unexpectedToken[0]}`;
    const sourceLine = lines.find((line) => /^\s*\d+ \|/.test(line));
    if (sourceLine) return `${lines[0]} in "${sourceLine.trim()}"`;
    return (lines[0] ?? '').slice(0, 300);
  };
  const result = { problems: [], vertexIds: null, edgeCount: null, labelTexts: null, looks: null };
  try {
    await mermaid.parse(code);
  } catch (error) {
    result.problems.push(`parse: ${summarize(error)}`);
    return result;
  }
  try {
    const diagram = await mermaid.mermaidAPI.getDiagramFromText(code);
    const vertices = diagram.db.getVertices();
    result.vertexIds = vertices instanceof Map ? [...vertices.keys()] : Object.keys(vertices);
    result.edgeCount = diagram.db.getEdges().length;
  } catch (error) {
    result.problems.push(`parse: reading the parsed nodes failed: ${summarize(error)}`);
    return result;
  }
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
      // Node elements have ids ending in "flowchart-<node id>-<n>" on 11.x
      // and 12.x (12.x puts the SVG id in front). Mermaid 12 can draw a
      // subgraph box in place of a node, so compare the ids, not the count.
      const drawnIds = [];
      for (const nodeElement of svgRoot.querySelectorAll('g.node')) {
        const match = (nodeElement.id ?? '').match(/flowchart-(.+)-\d+$/);
        drawnIds.push(match ? match[1] : `<element id "${nodeElement.id}">`);
      }
      const notDrawn = result.vertexIds.filter((id) => !drawnIds.includes(id));
      const notParsed = drawnIds.filter((id) => !result.vertexIds.includes(id));
      if (notDrawn.length > 0) result.problems.push(`render: parsed but not drawn: ${notDrawn.join(', ')}`);
      if (notParsed.length > 0) result.problems.push(`render: drawn but not parsed: ${notParsed.join(', ')}`);
      if (drawnIds.length !== new Set(drawnIds).size) result.problems.push('render: a node is drawn twice');
      // The look each node was drawn in; Mermaid 11.12.0 does not record it
      result.looks = [...new Set([...svgRoot.querySelectorAll('g.node')]
        .map((nodeElement) => nodeElement.getAttribute('data-look'))
        .filter((look) => look !== null))];
      // The text of every HTML label (nodes, edge labels, subgraph titles).
      // Both configurations draw labels as HTML; SVG text labels (and the
      // title) are not collected.
      result.labelTexts = [...svgRoot.querySelectorAll('foreignObject')]
        .map((label) => label.textContent.replace(/\s+/g, ' ').trim());
    }
  } catch (error) {
    result.problems.push(`render: ${summarize(error)}`);
  }
  return result;
}

const duplicatesOf = (ids) => [...new Set(ids.filter((id, index) => ids.indexOf(id) !== index))];

const definedIdsOf = (entry) => [...entry.defined_node_ids, ...entry.defined_artifact_ids];

// Checks that need only the manifest, not Mermaid: they run once per case,
// also for cases that Mermaid cannot parse.
function checkManifest(entry) {
  const problems = [];
  const definedIds = definedIdsOf(entry);
  const duplicates = duplicatesOf(definedIds);
  if (duplicates.length > 0) problems.push(`nodes: defined more than once: ${duplicates.join(', ')}`);
  const shownNodeCount = new Set(entry.defined_node_ids).size;
  if (shownNodeCount !== entry.expected_node_count) {
    problems.push(`nodes: the workflow has ${entry.expected_node_count} distinct ids, the diagram defines ${shownNodeCount} nodes`);
  }
  const strayReferences = [...new Set(entry.referenced_ids.filter((id) => !definedIds.includes(id)))];
  if (strayReferences.length > 0) problems.push(`nodes: class or click line for an undefined id: ${strayReferences.join(', ')}`);
  const duplicateSubgraphs = duplicatesOf(entry.defined_subgraph_ids);
  if (duplicateSubgraphs.length > 0) problems.push(`subgraphs: defined more than once: ${duplicateSubgraphs.join(', ')}`);
  return problems;
}

// Compare the nodes Mermaid parsed with the ids putior defined
function compareNodes(entry, vertexIds) {
  const problems = [];
  const definedIds = definedIdsOf(entry);
  const phantoms = vertexIds.filter((id) => !definedIds.includes(id));
  if (phantoms.length > 0) problems.push(`nodes: used but never defined: ${phantoms.join(', ')}`);
  const missing = [...new Set(definedIds.filter((id) => !vertexIds.includes(id)))];
  if (missing.length > 0) problems.push(`nodes: defined but not parsed: ${missing.join(', ')}`);
  return problems;
}

// Every "-->" line of the diagram must be an edge Mermaid parsed
function compareEdges(entry, edgeCount) {
  return edgeCount === entry.expected_edge_count
    ? []
    : [`edges: the diagram has ${entry.expected_edge_count} edge lines, Mermaid parsed ${edgeCount} edges`];
}

// The look set in the frontmatter must be the look Mermaid drew
function compareLook(entry, looks) {
  if (!entry.expected_look) return [];
  const otherLooks = looks.filter((look) => look !== entry.expected_look);
  return otherLooks.length > 0
    ? [`look: the frontmatter sets "${entry.expected_look}", Mermaid drew ${otherLooks.map((look) => `"${look}"`).join(', ')}`]
    : [];
}

// Every expected text must be the whole text of one label
function compareTexts(entry, labelTexts) {
  const notShown = (entry.expected_texts ?? [])
    .filter((text) => !labelTexts.includes(text.replace(/\s+/g, ' ').trim()));
  return notShown.length > 0
    ? [`text: no label shows ${notShown.map((text) => JSON.stringify(text)).join(', ')}`]
    : [];
}

// One page per Mermaid version and configuration
async function openPage(browser, mermaidVersion, config) {
  const page = await browser.newPage();
  await page.setContent('<!doctype html><html><body></body></html>');
  await page.addScriptTag({ path: mermaidVersion.script });
  await page.evaluate((config) => mermaid.initialize(config), config);
  return page;
}

const problemsByCase = new Map(manifest.map((entry) => [entry.name, []]));
for (const entry of manifest) {
  if (entry.error) {
    problemsByCase.get(entry.name).push(`R generate: ${entry.error}`);
  } else {
    for (const problem of checkManifest(entry)) problemsByCase.get(entry.name).push(`corpus ${problem}`);
  }
}

const browser = await chromium.launch();
try {
  for (const mermaidVersion of mermaidVersions) {
    for (const [configName, config] of Object.entries(mermaidConfigs)) {
      const label = `${mermaidVersion.version}/${configName}`;
      let page = await openPage(browser, mermaidVersion, config);
      for (const entry of manifest) {
        if (entry.error) continue;
        const code = fs.readFileSync(path.join(corpusDir, entry.file), 'utf8');
        let timer;
        const timeout = new Promise((resolve) => {
          timer = setTimeout(() => resolve(null), caseTimeoutMs);
        });
        const result = await Promise.race([page.evaluate(checkInPage, code), timeout]);
        clearTimeout(timer);
        const problems = [];
        if (result === null) {
          problems.push(`render: no result after ${caseTimeoutMs / 1000} s`);
          await page.close();
          page = await openPage(browser, mermaidVersion, config);
        } else {
          problems.push(...result.problems);
          if (result.vertexIds) problems.push(...compareNodes(entry, result.vertexIds));
          if (result.edgeCount !== null) problems.push(...compareEdges(entry, result.edgeCount));
          if (result.labelTexts) problems.push(...compareTexts(entry, result.labelTexts));
          if (result.looks) problems.push(...compareLook(entry, result.looks));
        }
        for (const problem of problems) problemsByCase.get(entry.name).push(`${label} ${problem}`);
      }
      await page.close();
    }
  }
} finally {
  await browser.close();
}

// "<where> <kind>: <message>" -> kind
const kindOf = (problem) => problem.split(' ')[1].replace(/:$/, '');

let failureCount = setupProblems.length;
for (const problem of setupProblems) console.log(`SETUP  ${problem}`);
const counts = { PASS: 0, XFAIL: 0, FAIL: 0, XPASS: 0 };
for (const entry of manifest) {
  const problems = problemsByCase.get(entry.name);
  const expected = expectedFailures[entry.name];
  const unexpectedProblems = expected
    ? problems.filter((problem) => !expected.problems.includes(kindOf(problem)))
    : problems;
  let status;
  if (problems.length === 0) status = expected ? 'XPASS' : 'PASS';
  else if (!expected) status = 'FAIL';
  else status = unexpectedProblems.length > 0 ? 'FAIL' : 'XFAIL';
  counts[status] += 1;
  if (status === 'FAIL' || status === 'XPASS') failureCount += 1;
  console.log(`${status.padEnd(6)} ${entry.name}${expected ? `  (${expected.issue})` : ''}`);
  if (status === 'XPASS') console.log('         passes now: remove it from expected-failures.json');
  if (status === 'FAIL' && expected) {
    console.log(`         known failure (${expected.problems.join(', ')}), but it also has other problems:`);
  }
  // Same problem on several versions/configurations: print it once with the list of where.
  const grouped = new Map();
  for (const problem of problems) {
    const [where, ...rest] = problem.split(' ');
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

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const { extractClasses, generateInventories, generateFlagSource, flags } = require("./build");

const wrap = (record) => `{- BEGIN COPY -}
classes =
    ${record}

type Var = Var String

unrelated = { name = "root" }
{- END COPY -}`;

test("extracts the entire classes record, ignoring comments and unrelated definitions", () => {
  const { pairs } = extractClasses(wrap(`{ root = "root"
    -- , ignored = "root"
    , added = "new-class"
    }`));
  assert.deepEqual(pairs, [
    { key: "root", value: "root" },
    { key: "added", value: "new-class" },
  ]);
  const inventory = generateInventories(pairs, ["padding", "addedFlag"]);
  assert.deepEqual([...inventory.matchAll(/Generated\.classes\.(\w+), "(\w+)"/g)]
    .map((match) => match.slice(1)), [["root", "root"], ["added", "added"]]);
  assert.deepEqual([...inventory.matchAll(/Flag\.(\w+)/g)].map((match) => match[1]),
    ["Flag", "padding", "addedFlag"]);
});

test("real-source metadata references every class field and flag in source order", () => {
  const source = fs.readFileSync(path.join(__dirname, "Generate.elm"), "utf8");
  const { pairs } = extractClasses(source);
  const inventory = generateInventories(pairs, flags);
  assert.ok(pairs.length > 0);
  assert.equal(inventory, fs.readFileSync(path.join(__dirname, "../tests/Generated/Inventories.elm"), "utf8"));
  const extended = extractClasses(source.replace('{ root = "elm-ui-root"',
    '{ newlyAdded = "newly-added"\n    , root = "elm-ui-root"')).pairs;
  assert.deepEqual(extended, [{ key: "newlyAdded", value: "newly-added" }, ...pairs]);
  assert.match(generateInventories(extended, flags), /Generated\.classes\.newlyAdded/);
  const flagSource = generateFlagSource(flags);
  assert.deepEqual([...flagSource.matchAll(/^(\w+) : Flag$/gm)].map((match) => match[1]),
    ["skip", ...flags]);
  assert.deepEqual([...inventory.matchAll(/Flag\.(\w+)/g)].map((match) => match[1]),
    ["Flag", ...flags]);
});

test("rejects collisions and duplicate fields", () => {
  assert.throws(() => extractClasses(wrap('{ root = "same", added = "same" }')), /collisions/);
  assert.throws(() => extractClasses(wrap('{ root = "one", root = "two" }')), /Duplicate class field/);
});

test("fails closed on unsupported or malformed class definitions", () => {
  for (const record of [
    '{ root = "root", added = other }',
    '{ root = "root", added = "a" ++ "b" }',
    '{ root = "root", added = ("added") }',
    '{ root = "root", added = "" }',
    '{ root = "root", added = "escaped\\n" }',
    '{ root = "root", added = """multiline""" }',
    '{ root = "root", added = { nested = "value" } }',
    '{ root = "root" {- block comment -}, added = "added" }',
    '{ root = "root", }',
    '{ root = "root" added = "added" }',
    '{ root = "root"',
    '{}',
    '{ base | root = "root" }',
    '{ root = "root" } |> transform',
    '{ root = "root" }\n    |> transform',
    '{ root = "root" }\n++ other',
    'other',
  ]) {
    assert.throws(() => extractClasses(wrap(record)), /Unsupported classes record/, record);
  }
  assert.throws(() => extractClasses(wrap('{ root = "root" }\n\nclasses = {}')),
    /Duplicate classes definition/);
});

test("COPY markers must exist exactly once and in order", () => {
  const source = wrap('{ root = "root" }');
  for (const invalid of [
    source.replace("{- BEGIN COPY -}", ""),
    source.replace("{- END COPY -}", ""),
    `{- BEGIN COPY -}${source}`,
    `${source}{- END COPY -}`,
    "{- END COPY -}{- BEGIN COPY -}",
  ]) {
    assert.throws(() => extractClasses(invalid), /unique, ordered/);
  }
});

test("all 32 flags fit, but adding a 33rd fails", () => {
  const atCapacity = Array.from({ length: 32 }, (_, i) => `flag${i}`);
  assert.match(generateFlagSource(atCapacity), /flag31 : Flag/);
  assert.throws(() => generateFlagSource([...atCapacity, "overflowFlag"]), /Flag overflow: 33/);
});

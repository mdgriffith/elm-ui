const runElm = require("@kachkaev/run-elm").default;
const fs = require("fs");
const path = require("path");
const child = require("child_process");
const chokidar = require("chokidar");

// ─── Deterministic generation ────────────────────────────────────────────────

const flags = [
  "padding",
  "spacing",
  "fontSize",
  "fontFamily",
  "width",
  "height",
  "fontAlignment",
  "fontWeight",
  "fontColor",
  "fontGradient",
  "fontAdjustment",
  "fontEllipsis",
  "id",
  "txtShadows",
  "shadows",
  "overflow",
  "cursor",
  "transform",
  "borderWidth",
  "yAlign",
  "xAlign",
  "xContentAlign",
  "yContentAlign",
  "focus",
  "active",
  "hover",
  "gridTemplate",
  "gridPosition",
  "widthBetween",
  "heightBetween",
  "background",
  "event",
];

const flagBase = `import Internal.BitField as BitField exposing (BitField, Bits)


type IsFlag = IsFlag


type alias Field =
    Bits


type alias Flag =
    BitField IsFlag


none : Field
none =
    BitField.init


merge : Flag -> Flag -> Flag
merge one two =
    if BitField.fieldEqual skip one then
        two

    else
        BitField.mergeField one two


{-| Add a flag to a field.
-}
add : Flag -> Field -> Field
add myFlag myField =
   BitField.flipIf myFlag True myField


skip : Flag
skip =
    BitField.first 0`;

/**
 * Validate the flag list and return the generated Internal.Flag source.
 * Throws if there are too many flags.
 */
function generateFlagSource(flagList) {
  if (flagList.length > 32) {
    throw new Error(
      `Flag overflow: ${flagList.length} flags defined but the limit is 32.`
    );
  }

  let items = "";
  let previous = "skip";
  for (const flag of flagList) {
    items += `\n\n${flag} : Flag\n${flag} =\n    BitField.next 1 ${previous}\n`;
    previous = flag;
  }

  return `module Internal.Flag exposing (..)

{-| THIS FILE IS GENERATED, NO TOUCHY 

This file is generated via 'bun run stylesheet' in the elm-ui repository
  
-}


${flagBase}

${items}
`;
}

/**
 * Validate that all class values in the BEGIN COPY block are unique.
 * Throws with details if any collision is found.
 */
function validateClassCollisions(copyBlock) {
  // Extract key = "value" pairs from the Elm record
  const pairs = [];
  const re = /,?\s+(\w+)\s*=\s*"([^"]+)"/g;
  let m;
  while ((m = re.exec(copyBlock)) !== null) {
    pairs.push({ key: m[1], value: m[2] });
  }

  const seen = new Map(); // value -> key
  const collisions = [];
  for (const { key, value } of pairs) {
    if (seen.has(value)) {
      collisions.push(
        `  "${value}" is used by both "${seen.get(value)}" and "${key}"`
      );
    } else {
      seen.set(value, key);
    }
  }

  if (collisions.length > 0) {
    throw new Error(
      `Class value collisions detected:\n${collisions.join("\n")}`
    );
  }
}

/**
 * Run the Elm generator and return all expected file contents.
 * This is the single deterministic function that produces all strings.
 */
async function generate() {
  const root = process.cwd();

  let { output } = await runElm("stylesheets/Generate.elm");
  process.chdir(root);

  const elmSource = fs.readFileSync("stylesheets/Generate.elm", "utf8");

  const start = elmSource.indexOf("{- BEGIN COPY -}");
  const end = elmSource.indexOf("{- END COPY -}");
  if (start === -1 || end === -1) {
    throw new Error("Could not find {- BEGIN COPY -} / {- END COPY -} markers in Generate.elm");
  }
  const copy = elmSource.slice(start, end);

  // Validate no class value collisions before writing
  validateClassCollisions(copy);

  const generatedElm = `module Internal.Style.Generated exposing (Var(..), classes, vars, stylesheet, lineHeightAdjustment)

{-| This file is generated via 'bun run stylesheet' in the elm-ui repository -}

${copy}stylesheet : String
stylesheet = """${output}"""
`;

  const flagElm = generateFlagSource(flags);

  return {
    "src/Internal/Style/Generated.elm": generatedElm,
    "stylesheets/generated/dev.min.css": output,
    "src/Internal/Flag.elm": flagElm,
  };
}

// ─── Tracked artifacts (checked by stylesheet:check) ─────────────────────────
// dev.min.css is gitignored and written by `bun run stylesheet` only.
const TRACKED_KEYS = [
  "src/Internal/Style/Generated.elm",
  "src/Internal/Flag.elm",
];

// ─── Write command (bun run stylesheet) ──────────────────────────────────────

async function write() {
  const artifacts = await generate();
  for (const [relPath, content] of Object.entries(artifacts)) {
    fs.mkdirSync(path.dirname(relPath), { recursive: true });
    fs.writeFileSync(relPath, content);
  }
  console.log("  -> Files regenerated");
}

// ─── Check command (bun run stylesheet:check) ─────────────────────────────────

async function check() {
  const artifacts = await generate();
  let stale = [];

  for (const relPath of TRACKED_KEYS) {
    const expected = artifacts[relPath];
    let current;
    try {
      current = fs.readFileSync(relPath, "utf8");
    } catch (_) {
      stale.push(`  MISSING: ${relPath}`);
      continue;
    }
    if (current !== expected) {
      stale.push(`  STALE:   ${relPath}`);
    }
  }

  if (stale.length > 0) {
    console.error("stylesheet:check failed — stale or missing artifacts:");
    stale.forEach((s) => console.error(s));
    console.error('\nRun "bun run stylesheet" to regenerate.');
    process.exit(1);
  } else {
    console.log("stylesheet:check passed — all artifacts are up to date.");
  }
}

// ─── Watch command (bun run watch-stylesheet) ─────────────────────────────────

async function watch() {
  chokidar
    .watch("./stylesheets/Generate.elm")
    .on("all", async (event, filePath) => {
      console.log("Stylesheet change detected");
      try {
        await write();
      } catch (e) {
        console.error(e.message);
      }
    });
}

// ─── Entry point ─────────────────────────────────────────────────────────────

function run() {
  const arg = process.argv[2];
  if (arg === "--check") {
    check().catch((e) => {
      console.error(e.message);
      process.exit(1);
    });
  } else if (arg === "--watch" || arg === "-w") {
    watch();
  } else {
    write().catch((e) => {
      console.error(e.message);
      process.exit(1);
    });
  }
}

run();

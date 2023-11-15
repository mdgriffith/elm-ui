const runElm = require("@kachkaev/run-elm").default;
const fs = require("fs");
const path = require("path");
const child = require("child_process");
const chokidar = require("chokidar");

async function gzip(file) {
  // --keep = keep the original file
  // --force = overwrite the exisign gzip file if it's there
  child.execSync("gzip --keep --force " + file);
}

async function build() {
  const root = process.cwd();

  let { output, debugLog } = await runElm("stylesheets/Generate.elm");
  process.chdir(root);

  const elmSource = fs.readFileSync("stylesheets/Generate.elm", "utf8");

  const start = elmSource.indexOf("{- BEGIN COPY -}");
  const end = elmSource.indexOf("{- END COPY -}");
  const copy = elmSource.slice(start, end);

  const elm = `module Internal.Style.Generated exposing (Var(..), classes, vars, stylesheet, lineHeightAdjustment)

{-| This file is generated via 'npm run stylesheet' in the elm-ui repository -}

${copy}stylesheet : String
stylesheet = """${output}"""
`;

  fs.writeFileSync("./src/Internal/Style/Generated.elm", elm);

  fs.writeFileSync("./stylesheets/generated/dev.min.css", output);
  // gzip("./stylesheets/generated/dev.min.css");

  fs.writeFileSync("./src/Internal/Flag.elm", build_flags(flags));

  console.log("  -> Files regenerated");
}

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

const base = `import Internal.BitField as BitField exposing (BitField, Bits)


type IsFlag = IsFlag


type alias Field
    = Bits


type alias Flag
    = BitField IsFlag


none : Field
none =
    BitField.init


{-| Add a flag to a field.
-}
add : Flag -> Field -> Field
add myFlag myField =
   BitField.flipIf myFlag True myField


skip : Flag 
skip =
    BitField.first 0`;

function build_flags(flags) {
  let items = "";
  let i = 0;
  let previous = "skip";
  for (const flag of flags) {
    items += `

${flag} : Flag
${flag} =
    BitField.next 1 ${previous}
`;
    i += 1;
    previous = flag;
  }
  if (i > 32) {
    console.warn(`You have ${i} flags. The limit is 32!`);
  }

  return `module Internal.Flag exposing (..)
{-| THIS FILE IS GENERATED, NO TOUCHY 

This file is generated via 'npm run stylesheet' in the elm-ui repository
  
-}


${base}

${items}

`;
}

async function watch() {
  chokidar
    .watch("./stylesheets/Generate.elm")
    .on("all", async (event, path) => {
      console.log("Stylesheet change detected");
      build();
    });
}

function run() {
  const watching = process.argv[2];
  if (watching == "--watch" || watching == "-w") {
    watch();
  } else {
    build();
  }
}

run();

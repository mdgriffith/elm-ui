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

  const elm = `module Internal.Style.Generated exposing (Var(..), classes, vars, stylesheet)

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
  "fontAdjustment",
  "id",
  "txtShadows",
  "shadows",
  "overflow",
  "cursor",
  "transform",
  "borderWidth",
  "yAlign",
  "xAlign",
  "focus",
  "active",
  "hover",
  "gridTemplate",
  "gridPosition",
  "widthBetween",
  "heightBetween",
  "isLink",
  "background",
  "event",
];

const base = `import Bitwise


viewBits : Int -> String
viewBits i =
    String.fromInt i ++ ":" ++ viewBitsHelper i 32


viewBitsHelper : Int -> Int -> String
viewBitsHelper field slot =
    if slot <= 0 then
        ""

    else if Bitwise.and slot field - slot == 0 then
        viewBitsHelper field (slot - 1) ++ "1"

    else
        viewBitsHelper field (slot - 1) ++ "0"


type Field
    = Field Int

type Flag
    = Flag Int

none : Field
none =
    Field 0


{-| If the query is in the truth, return True
-}
present : Flag -> Field -> Bool
present (Flag first) (Field fieldOne) =
    Bitwise.and first fieldOne - first == 0


{-| Add a flag to a field.
-}
add : Flag -> Field -> Field
add myFlag (Field one) =
    case myFlag of
        Flag first ->
            Field (Bitwise.or first one)

{-| Generally you want to use add, which keeps a distinction between Fields and Flags.

Merging will combine two fields

-}
merge : Field -> Field -> Field
merge (Field one) (Field three) =
    Field (Bitwise.or one three)


equal : Flag -> Flag -> Bool
equal (Flag one) (Flag two) =
    one - two == 0


flag : Int -> Flag
flag i =
    Flag
        (Bitwise.shiftLeftBy i 1)


skip : Flag 
skip =
    Flag 0
`;

function build_flags(flags) {
  let items = "";
  let i = 0;
  for (const flag of flags) {
    items += `

${flag} : Flag
${flag} =
    flag ${i}
`;
    i += 1;
  }
  if (i > 32) {
    console.warn(`You have ${i} flags. The limit is 32!`);
  }

  return `module Internal.Flag exposing (..)
{-| THIS FILE IS GENERATED, NO TOUCHY -}


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

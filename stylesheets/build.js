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

  fs.writeFileSync("./src2/Internal/Style/Generated.elm", elm);

  fs.writeFileSync("./stylesheets/generated/dev.min.css", output);
  gzip("./stylesheets/generated/dev.min.css");

  console.log("  -> Files regenerated");
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

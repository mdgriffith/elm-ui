const fs = require("fs");
const path = require("path");
const compileToString = require("node-elm-compiler").compileToString;

// {
//     template: "./tests-rendering/automation/templates/gather-styles.html",
//     target: "./tmp/test.html",
//     elm: "src/Tests/Run.elm",
//     replace:
//     elmOptions: { cwd: "./tests-rendering" },
//   }

async function compile_and_embed(config) {
  const elm_entry_module = fs.readFileSync(
    path.join(config.elmOptions.cwd, config.elm),
    "utf8"
  );

  const module_name = elm_entry_module
    .split(/[\r\n]+/)[0]
    .match(/module ([A-Za-z0-9\.]+)/i)[1];

  // we embed the compiled js to avoid having to start a server to read the app.
  await compileToString([config.elm], config.elmOptions).then(function (
    compiled_elm_code
  ) {
    // console.log(compiled_elm_code);
    const compiled = fs
      .readFileSync(config.template, "utf8")
      .replace(/~~_compiled_elm_code_~~/, () => compiled_elm_code)
      .replace(/~~_module_name_~~/, () => module_name);

    fs.writeFileSync(config.target, compiled);
  });
}

async function compile_to_string(config) {
  const elm_entry_module = fs.readFileSync(
    path.join(config.elmOptions.cwd, config.elm),
    "utf8"
  );

  const module_name = elm_entry_module
    .split(/[\r\n]+/)[0]
    .match(/module ([A-Za-z0-9\.]+)/i)[1];

  const compiled = await compileToString([config.elm], config.elmOptions).then(
    function (compiled_elm_code) {
      return fs
        .readFileSync(config.template, "utf8")
        .replace(/~~_module_name_~~/g, () => module_name)
        .replace(/~~_compiled_elm_code_~~/g, () => compiled_elm_code);
    }
  );
  return compiled;
}

async function get_module_name(config) {
  const elm_entry_module = fs.readFileSync(
    path.join(config.cwd, config.elm),
    "utf8"
  );

  const module_name = elm_entry_module
    .split(/[\r\n]+/)[0]
    .match(/module ([A-Za-z0-9\.]+)/i)[1];
  return module_name;
}

async function create_runner(config) {
  const elm_entry_module = fs.readFileSync(config.elm, "utf8");

  let module_name = elm_entry_module
    .split(/[\r\n]+/)[0]
    .match(/module ([A-Za-z0-9\.]+)/i)[1];

  const module_name_sentence = module_name.replace(/([A-Z])/g, " $1");

  const runner = fs
    .readFileSync(config.template, "utf8")
    .replace(/~~_module_name_~~/g, () => module_name)
    .replace(/~~_module_name_sentence_~~/g, () => module_name_sentence);
  fs.writeFileSync(config.target, runner);
}

exports.compile_and_embed = compile_and_embed;

exports.create_runner = create_runner;

exports.compile_to_string = compile_to_string;

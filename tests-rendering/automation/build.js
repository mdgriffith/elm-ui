const fs = require("fs");
const path = require("path");
const compileToString = require("node-elm-compiler").compileToString;

// {
//     template: "./tests-rendering/automation/templates/gather-styles.html",
//     target: "./tmp/test.html",
//     elm: "src/Tests/Run.elm",
//     elmOptions: { cwd: "./tests-rendering" },
//   }

async function compile_and_embed(config) {
  const template = fs.readFileSync(config.template);

  const elm_entry_module = fs.readFileSync(
    path.join(config.elmOptions.cwd, config.elm),
    "utf8"
  );
  //   console.log(elm_entry_module);
  const module_name = elm_entry_module
    .split(/[\r\n]+/)[0]
    .match(/module ([A-Za-z0-9\.]+)/i)[1];
  //   console.log(module_name);

  //   throw "Ugh";

  // we embed the compiled js to avoid having to start a server to read the app.
  await compileToString([config.elm], config.elmOptions).then(function (
    compiled_elm_code
  ) {
    const compiled = eval(`\`${template}\``);
    fs.writeFileSync(config.target, compiled);
  });
}

async function compile_to_string(config) {
  const template = fs.readFileSync(config.template);

  const elm_entry_module = fs.readFileSync(
    path.join(config.elmOptions.cwd, config.elm),
    "utf8"
  );
  //   console.log(elm_entry_module);
  const module_name = elm_entry_module
    .split(/[\r\n]+/)[0]
    .match(/module ([A-Za-z0-9\.]+)/i)[1];
  //   console.log(module_name);

  //   throw "Ugh";

  // we embed the compiled js to avoid having to start a server to read the app.
  const compiled = await compileToString([config.elm], config.elmOptions).then(
    function (compiled_elm_code) {
      return eval(`\`${template}\``);
    }
  );
  return compiled;
}

exports.compile_and_embed = compile_and_embed;

exports.compile_to_string = compile_to_string;

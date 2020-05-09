const fs = require("fs");
const program = require("commander");
const path = require("path");
const chalk = require("chalk");
const childProcess = require("child_process");
const build = require("./build.js");
const chokidar = require("chokidar");
const http = require("http");

var filepath = null;
program

  .arguments("<filepath>")
  .action(function (p) {
    filepath = p;
  })
  .parse(process.argv);

(async () => {
  var dir = "tmp";
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir);
  }

  console.log("Compiling tests");
  let content = await build.compile_to_string({
    template: "./tests-rendering/automation/templates/gather-styles.html",
    elm: filepath,
    elmOptions: { cwd: "./tests-rendering" },
  });
  console.log("Finished compiling");
  //   console.log(content);

  chokidar.watch("./tests-rendering/*.elm").on("all", (event, path) => {
    console.log("Changes detected, refresh!");
    content = build.compile_to_string({
      template: "./tests-rendering/automation/templates/gather-styles.html",
      elm: filepath,
      elmOptions: { cwd: "./tests-rendering" },
    });
  });
  console.log("Serving on http://localhost:8080");
  http
    .createServer(function (req, res) {
      res.writeHead(200, { "Content-Type": "text/html" });
      res.write(content);
      res.end();
    })
    .listen(8080);
})();

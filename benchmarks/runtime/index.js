const puppeteer = require('puppeteer');
const benchPage = require('./benchPage');
var compileToString = require("node-elm-compiler").compileToString;
const fs = require('fs');


function write_entrypoint(item) {

    const entrypoint = `module Main exposing (main)
import ${item.module}
import Render

main = Render.toProgram ${item.module}.${item.value}
`
    fs.writeFileSync('./tmp/Main.elm', entrypoint);
}

(async () => {
    const browser = await puppeteer.launch();
    var instances = [{ module: "Bench", value: "bench" }]
    var dir = "tmp"
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    }

    for (var i = 0; i < instances.length; i++) {
        var item = instances[i]
        write_entrypoint(item)
        var template = fs.readFileSync("./runtime/template/index.html")
        // we embed the compiled js to avoid having to start a server to read the app.
        await compileToString(["./tmp/Main.elm"], {}).then(function (compiled_elm_code) {
            const compiled = eval(`\`${template}\``)
            fs.writeFileSync("./tmp/index.html", compiled)
        });

        const page = await browser.newPage();
        const results = await benchPage(page);
        await page.close()
        console.log(results)
    }
    await browser.close();
})();

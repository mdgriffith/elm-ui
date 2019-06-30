const puppeteer = require('puppeteer');
const benchPage = require('./benchPage');
var compileToString = require("node-elm-compiler").compileToString;
const fs = require('fs');


function write_entrypoint(item) {

    const entrypoint = `module Main exposing (main)
import ${item.module}
import Benchmark.Render

main = Benchmark.Render.toProgram ${item.module}.${item.value}
`
    fs.writeFileSync('./tmp/Main.elm', entrypoint);
}

(async () => {
    const browser = await puppeteer.launch();
    var instances = [{ module: "Baseline", value: "bench" }
        , { module: "ManyElements", value: "elmUI1024" }
        , { module: "ManyElements", value: "elmUI128" }
        , { module: "ManyElements", value: "elmUI2048" }
        , { module: "ManyElements", value: "elmUI24" }
        , { module: "ManyElements", value: "elmUI256" }
        , { module: "ManyElements", value: "elmUI4096" }
        , { module: "ManyElements", value: "elmUI512" }
        , { module: "ManyElements", value: "elmUI64" }
        , { module: "ManyElements", value: "elmUI8192" }
        , { module: "ManyElements", value: "viewHtml1024" }
        , { module: "ManyElements", value: "viewHtml128" }
        , { module: "ManyElements", value: "viewHtml2048" }
        , { module: "ManyElements", value: "viewHtml24" }
        , { module: "ManyElements", value: "viewHtml256" }
        , { module: "ManyElements", value: "viewHtml4096" }
        , { module: "ManyElements", value: "viewHtml512" }
        , { module: "ManyElements", value: "viewHtml64" }
        , { module: "ManyElements", value: "viewHtml8192" }
        , { module: "ManyElements", value: "viewInline1024" }
        , { module: "ManyElements", value: "viewInline128" }
        , { module: "ManyElements", value: "viewInline2048" }
        , { module: "ManyElements", value: "viewInline24" }
        , { module: "ManyElements", value: "viewInline256" }
        , { module: "ManyElements", value: "viewInline4096" }
        , { module: "ManyElements", value: "viewInline512" }
        , { module: "ManyElements", value: "viewInline64" }
        , { module: "ManyElements", value: "viewInline8192" }

    ]


    var dir = "tmp"
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    }

    var allResults = []

    for (var i = 0; i < instances.length; i++) {
        var item = instances[i]
        write_entrypoint(item)
        var template = fs.readFileSync("./runtime/template/index.html")
        // we embed the compiled js to avoid having to start a server to read the app.
        await compileToString(["./tmp/Main.elm"], { optimize: true }).then(function (compiled_elm_code) {
            const compiled = eval(`\`${template}\``)
            fs.writeFileSync("./tmp/index.html", compiled)
        });

        const page = await browser.newPage();
        const results = await benchPage(page);
        await page.close()
        console.log(results)
        allResults.push(results)
    }
    await browser.close();

    var resultsDir = "results"
    if (!fs.existsSync(resultsDir)) {
        fs.mkdirSync(resultsDir);
    }
    fs.writeFileSync(`./${resultsDir}/1.1.1-candidate-optimized.json`, JSON.stringify(allResults))
})();

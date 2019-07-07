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
    fs.writeFileSync('./benchmarks/tmp/Main.elm', entrypoint);
}

async function compile_and_embed(config) {
    var template = fs.readFileSync(config.template)
    // we embed the compiled js to avoid having to start a server to read the app.
    await compileToString(config.elm, config.elmOptions).then(function (compiled_elm_code) {
        const compiled = eval(`\`${template}\``)
        fs.writeFileSync(config.target, compiled)
    });
}


function regroupResults(results) {
    var regrouped = {}

    for (var i = 0; i < results.length; i++) {
        if (results[i].group) {

            var reorged = {
                count: results[i].count
                , fps: results[i].frames.fps
                , timeToFirstPaintMS: results[i].perf.TimeToFirstPaintMS
                , nodes: results[i].perf.Nodes
                , layoutSeconds: results[i].perf.LayoutDuration
                , recalcStyleSeconds: results[i].perf.RecalcStyleDuration
                , scriptDurationSeconds: results[i].perf.ScriptDuration
            }
            if (results[i].group in regrouped) {
                regrouped[results[i].group].results.push(reorged)
            } else {
                regrouped[results[i].group] = { results: [reorged], name: results[i].group }
            }
        }
    }
    return Object.values(regrouped)
}


async function write_results(allResults) {
    var resultsDir = "benchmarks/results"
    if (!fs.existsSync(resultsDir)) {
        fs.mkdirSync(resultsDir);
    }
    var results = JSON.stringify(allResults)
    var template = fs.readFileSync("./benchmarks/runtime/template/viewResults.html")
    // we embed the compiled js to avoid having to start a server to read the app.
    await compileToString(["./src/View/Results.elm"], { optimize: true, cwd: "./benchmarks" }).then(function (compiled_elm_code) {
        const compiled = eval(`\`${template}\``)
        fs.writeFileSync(`./${resultsDir}/1.1.1-cand.html`, compiled)
    });

    // fs.writeFileSync(`./${resultsDir}/1.1.1-candidate-optimized.json`, results)
}




(async () => {
    const browser = await puppeteer.launch();
    var instances = [{ module: "Baseline", group: null, value: "bench" }
        , { module: "ManyElements", group: "elmUI", count: 1024, value: "elmUI1024" }
        , { module: "ManyElements", group: "elmUI", count: 128, value: "elmUI128" }
        , { module: "ManyElements", group: "elmUI", count: 2048, value: "elmUI2048" }
        , { module: "ManyElements", group: "elmUI", count: 24, value: "elmUI24" }
        , { module: "ManyElements", group: "elmUI", count: 256, value: "elmUI256" }
        , { module: "ManyElements", group: "elmUI", count: 4096, value: "elmUI4096" }
        , { module: "ManyElements", group: "elmUI", count: 512, value: "elmUI512" }
        , { module: "ManyElements", group: "elmUI", count: 64, value: "elmUI64" }
        , { module: "ManyElements", group: "elmUI", count: 8192, value: "elmUI8192" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 1024, value: "elmUIVCSS1024" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 128, value: "elmUIVCSS128" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 2048, value: "elmUIVCSS2048" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 24, value: "elmUIVCSS24" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 256, value: "elmUIVCSS256" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 4096, value: "elmUIVCSS4096" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 512, value: "elmUIVCSS512" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 64, value: "elmUIVCSS64" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 8192, value: "elmUIVCSS8192" }
        , { module: "ManyElements", group: "viewHtml", count: 1024, value: "viewHtml1024" }
        , { module: "ManyElements", group: "viewHtml", count: 128, value: "viewHtml128" }
        , { module: "ManyElements", group: "viewHtml", count: 2048, value: "viewHtml2048" }
        , { module: "ManyElements", group: "viewHtml", count: 24, value: "viewHtml24" }
        , { module: "ManyElements", group: "viewHtml", count: 256, value: "viewHtml256" }
        , { module: "ManyElements", group: "viewHtml", count: 4096, value: "viewHtml4096" }
        , { module: "ManyElements", group: "viewHtml", count: 512, value: "viewHtml512" }
        , { module: "ManyElements", group: "viewHtml", count: 64, value: "viewHtml64" }
        , { module: "ManyElements", group: "viewHtml", count: 8192, value: "viewHtml8192" }
        , { module: "ManyElements", group: "viewInline", count: 1024, value: "viewInline1024" }
        , { module: "ManyElements", group: "viewInline", count: 128, value: "viewInline128" }
        , { module: "ManyElements", group: "viewInline", count: 2048, value: "viewInline2048" }
        , { module: "ManyElements", group: "viewInline", count: 24, value: "viewInline24" }
        , { module: "ManyElements", group: "viewInline", count: 256, value: "viewInline256" }
        , { module: "ManyElements", group: "viewInline", count: 4096, value: "viewInline4096" }
        , { module: "ManyElements", group: "viewInline", count: 512, value: "viewInline512" }
        , { module: "ManyElements", group: "viewInline", count: 64, value: "viewInline64" }
        , { module: "ManyElements", group: "viewInline", count: 8192, value: "viewInline8192" }

    ]


    var dir = "tmp"
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    }

    var dir = "./benchmarks/tmp"
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    }

    var allResults = []

    for (var i = 0; i < instances.length; i++) {
        var item = instances[i]
        write_entrypoint(item)
        var template = fs.readFileSync("./benchmarks/runtime/template/run.html")
        var cssom = fs.readFileSync("./experiments/virtual-css/cssom.js")
        // we embed the compiled js to avoid having to start a server to read the app.
        await compileToString(["tmp/Main.elm"], { optimize: true, cwd: "./benchmarks" }).then(function (compiled_elm_code) {
            const compiled = eval(`\`${template}\``)
            fs.writeFileSync("./tmp/run.html", compiled)
        });

        const page = await browser.newPage();
        const results = await benchPage(page);
        results.group = item.group
        results.count = item.count
        await page.close()
        console.log(results)
        allResults.push(results)
    }
    await browser.close();

    allResults = regroupResults(allResults)

    write_results(allResults)

})();

const puppeteer = require('puppeteer');
const benchPage = require('./benchPage');
const chalk = require('chalk');
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
                name: results[i].name
                , link: results[i].link
                , count: results[i].count
                , fps: results[i].frames.fps
                , timeToFirstPaintMS: results[i].perf.TimeToFirstPaintMS
                , nodes: results[i].perf.Nodes
                , coldRender: {
                    layoutSeconds: results[i].perf.LayoutDuration
                    , recalcStyleSeconds: results[i].perf.RecalcStyleDuration
                    , scriptDurationSeconds: results[i].perf.ScriptDuration

                }
                , warmRender: {
                    layoutSeconds: results[i].afterRefresh.LayoutDuration
                    , recalcStyleSeconds: results[i].afterRefresh.RecalcStyleDuration
                    , scriptDurationSeconds: results[i].afterRefresh.ScriptDuration

                }
                , extendedRender: {
                    layoutSeconds: results[i].afterAnimation.LayoutDuration
                    , recalcStyleSeconds: results[i].afterAnimation.RecalcStyleDuration
                    , scriptDurationSeconds: results[i].afterAnimation.ScriptDuration

                }

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


var contain = [{ module: "Contain", group: "html", count: 1024, value: "viewHtml8192" }
    , { module: "Contain", group: "contain", count: 128, value: "viewHtmlContain8192" }]


async function writeResults(allResults, resultsDir, name) {

    if (!fs.existsSync(resultsDir)) {
        fs.mkdirSync(resultsDir);
    }
    var results = JSON.stringify(allResults)
    var template = fs.readFileSync("./benchmarks/runtime/template/viewResults.html")
    // we embed the compiled js to avoid having to start a server to read the app.
    await compileToString(["./src/View/Results.elm"], { optimize: true, cwd: "./benchmarks" }).then(function (compiled_elm_code) {
        const compiled = eval(`\`${template}\``)
        fs.writeFileSync(`./${resultsDir}/${name}/index.html`, compiled)
    });

    // fs.writeFileSync(`./${resultsDir}/1.1.1-candidate-optimized.json`, results)
}


(async () => {
    const browser = await puppeteer.launch();


    var instances = [
        { module: "ManyElements", group: "elmUI", count: 1024, value: "elmUI1024" }
        , { module: "ManyElements", group: "elmUI", count: 128, value: "elmUI128" }
        , { module: "ManyElements", group: "elmUI", count: 2048, value: "elmUI2048" }
        , { module: "ManyElements", group: "elmUI", count: 24, value: "elmUI24" }
        , { module: "ManyElements", group: "elmUI", count: 4096, value: "elmUI4096" }
        , { module: "ManyElements", group: "elmUI", count: 8192, value: "elmUI8192" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 1024, value: "elmUIVCSS1024" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 2048, value: "elmUIVCSS2048" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 24, value: "elmUIVCSS24" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 4096, value: "elmUIVCSS4096" }
        , { module: "ManyElements", group: "elmUIVCSS", count: 8192, value: "elmUIVCSS8192" }
        , { module: "ManyElements", group: "viewHtml", count: 1024, value: "viewHtml1024" }
        , { module: "ManyElements", group: "viewHtml", count: 2048, value: "viewHtml2048" }
        , { module: "ManyElements", group: "viewHtml", count: 24, value: "viewHtml24" }
        , { module: "ManyElements", group: "viewHtml", count: 4096, value: "viewHtml4096" }
        , { module: "ManyElements", group: "viewHtml", count: 8192, value: "viewHtml8192" }
        , { module: "ManyElements", group: "viewInline", count: 1024, value: "viewInline1024" }
        , { module: "ManyElements", group: "viewInline", count: 2048, value: "viewInline2048" }
        , { module: "ManyElements", group: "viewInline", count: 24, value: "viewInline24" }
        , { module: "ManyElements", group: "viewInline", count: 4096, value: "viewInline4096" }
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
    const resultsDir = "benchmarks/results"
    const resultName = "1.2-cand"

    if (!fs.existsSync(`./${resultsDir}/${resultName}/instances/`)) {
        fs.mkdirSync(`./${resultsDir}/${resultName}/instances/`, { recursive: true });
    }

    console.log(`Beginning benchmark for ${resultName} →`)

    for (var i = 0; i < instances.length; i++) {
        var item = instances[i]
        write_entrypoint(item)
        const test_file = `${resultsDir}/${resultName}/instances/${item.value}.html`
        var template = fs.readFileSync("./benchmarks/runtime/template/run.html")
        var cssom = fs.readFileSync("./experiments/virtual-css/cssom.js")
        // we embed the compiled js to avoid having to start a server to read the app.
        await compileToString(["tmp/Main.elm"], { optimize: true, cwd: "./benchmarks" }).then(function (compiled_elm_code) {
            const compiled = eval(`\`${template}\``)
            fs.writeFileSync(test_file, compiled)
        });

        const page = await browser.newPage();
        const results = await benchPage(page, test_file);
        results.group = item.group
        results.count = item.count
        await page.close()
        // console.log(results)
        console.log("    Benchmark of " + chalk.green(`${item.module}.${item.value}`) + " complete")
        allResults.push(results)
    }
    await browser.close();

    allResults = regroupResults(allResults)

    writeResults(allResults, resultsDir, resultName)
    console.log()
    console.log("Benchmark complete")
    console.log("   → " + chalk.green(`${resultsDir}/${resultName}/index.html`))

})();

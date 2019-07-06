const compileToString = require("node-elm-compiler").compileToString;
const { Builder, By, Key, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const firefox = require('selenium-webdriver/firefox');
const fs = require('fs');
const program = require('commander');
const path = require("path");
const chalk = require('chalk');
const childProcess = require('child_process')

program.option('-s, --sauce', 'run tests on sauce labs')
    .option('--chrome', 'run only chrome tests')
    .option('--firefox', 'run only firefox tests')
    .option('--build [value]', 'Set build number for sauce labs')
    .option('--name [value]', 'Set run name for sauce labs')
    .parse(process.argv)


// 'Windows 10'
const windows = [
    {
        browser: "chrome"
        , browserVersion: "latest"
    },
    {
        browser: "firefox"
        , browserVersion: "latest"
    },
    {
        browser: "safari"
        , browserVersion: "latest"
    },
    {
        browser: "MicrosoftEdge"
        , browserVersion: "latest"
    },
    {
        browser: "internet explorer"
        , browserVersion: "latest"
    }
]

// "macOS 10.14"
const osx = {
    chrome: {
        platform: "macOS 10.14"
        , browser: "chrome"
        , browserVersion: "latest"
    },
    firefox: {
        platform: "macOS 10.14"
        , browser: "firefox"
        , browserVersion: "latest"
    },
    safari: {
        platform: "macOS 10.14"
        , browser: "safari"
        , browserVersion: "latest"
    }
}


function prepare_all_envs(config) {
    var envs = []

    for (i = 0; i < windows.length; i++) {
        envs.push({
            browser: windows[i].browser,
            browserVersion: windows[i].browserVersion,
            platform: "Windows 10",
            build: config.build,
            name: config.name
        })
    }

    for (i = 0; i < osx.length; i++) {
        envs.push({
            browser: osx[i].browser,
            browserVersion: osx[i].browserVersion,
            platform: "macOS 10.14",
            build: config.build,
            name: config.name
        })
    }


    return envs
}

async function compile_and_embed(config) {
    var template = fs.readFileSync(config.template)
    // we embed the compiled js to avoid having to start a server to read the app.
    await compileToString(config.elm, config.elmOptions).then(function (compiled_elm_code) {
        const compiled = eval(`\`${template}\``)
        fs.writeFileSync(config.target, compiled)
    });
}




function prepare_sauce_driver(env) {
    const username = process.env.SAUCE_USERNAME;
    const accessKey = process.env.SAUCE_ACCESS_KEY;

    driver = new webdriver.Builder().withCapabilities({
        'browserName': env.browser,
        'platformName': env.platform,
        'browserVersion': env.browserVersion,
        /* Pass Sauce User Name and Access Key */
        'sauce:options': {
            'username': username,
            'accessKey': accessKey,
            'build': env.build,
            'name': env.name
        }
    }).usingServer("https://@ondemand.saucelabs.com:443/wd/hub").build();

    return driver;
}

async function prepare_local_driver(env) {
    const firefoxOptions = new firefox.Options().headless()
    const chromeOptions = new chrome.Options().headless()

    let driver = await new Builder()
        .forBrowser(env.browser)
        .setChromeOptions(chromeOptions)
        .setFirefoxOptions(firefoxOptions)
        .build();

    return driver;
}

async function run_test(driver, url) {

    var results = null
    try {
        await driver.get(url);
        await driver.wait(until.titleIs('tests finished'), 60000);
        results = await driver.executeScript("return test_results")
    } finally {
        await driver.quit();
    }
    return results
}



(async () => {
    var dir = "tmp"
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    }

    await compile_and_embed({
        template: "./tests/automation/templates/gather-styles.html",
        target: "./tmp/test.html",
        elm: ["Tests/Run.elm"],
        elmOptions: { cwd: "./tests" }
    })
    console.log("Tests done compiling")

    if (program.sauce) {
        const build = program.build
        const name = program.name

        if (build == null || name == null) {
            throw ("A Build and a Name must be specified.");
        }


        var results = []

        // Publish to netlify
        childProcess.execSync("sh tests/automation/publish-file.sh", {
            env: {
                FILE: "test.html",
                BUILD: program.build,
                NAME: program.name
            }
        })
        var url = `http://elm-ui-testing.netlify.com/tests/${program.build}/${program.name}/`
        console.log(`Running sauce labs test ${url}`)


        const envs = prepare_all_envs({ build: build, name: name })
        for (i = 0; i < envs.length; i++) {
            var driver = prepare_sauce_driver(envs[i])
            results.push(await run_test(driver, url))
        }


    } else {

        // Run chrome if nothing else is selected
        if (program.chrome || (!program.chrome && !program.firefox)) {
            console.log("Running locally on Chrome...")
            const driver = await prepare_local_driver(osx.chrome)
            var results = await run_test(driver, "file://" + path.resolve('./tmp/test.html'))
            print_results(results);
        }
        if (program.firefox) {
            console.log("Running locally on Firefox...")
            const driver = await prepare_local_driver(osx.firefox)
            var results = await run_test(driver, "file://" + path.resolve('./tmp/test.html'))
            print_results(results);
        }

    }
})();


function print_results(results) {
    var passed = 0
    var failed = 0
    var i;
    for (i = 0; i < results.length; i++) {
        passed = 0
        failed = 0
        console.log(results[i].label)
        for (j = 0; j < results[i].results.length; j++) {
            if (results[i].results[j][1] == null) {
                passed = passed + 1
            } else {
                failed = failed + 1
                console.log("    " + chalk.red("fail") + " -> " + results[i].results[j][0])
                console.log("        " + results[i].results[j][1].description)
            }
        }
        if (failed == 0) {
            console.log(chalk.green(`    All ${passed} tests passed`))
        } else {
            console.log(chalk.green(`    ${passed} tests passed`))
            console.log(chalk.red(`    ${failed} tests failed`))
        }
        console.log()
    }
}
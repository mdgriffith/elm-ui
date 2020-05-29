const { Builder, By, Key, until } = require("selenium-webdriver");
const chrome = require("selenium-webdriver/chrome");
const firefox = require("selenium-webdriver/firefox");
const fs = require("fs");
const program = require("commander");
const path = require("path");
const chalk = require("chalk");
const childProcess = require("child_process");
const compile_and_embed = require("./build.js").compile_and_embed;

program
  .option("-s, --sauce", "run tests on sauce labs")
  .option("--chrome", "run chrome tests (default)")
  .option("--firefox", "run firefox tests")
  .option("--ie", "run ie tests")
  .option("--edge", "run edge tests")
  .option("--build [value]", "Set build number for sauce labs")
  .option("--name [value]", "Set run name for sauce labs")
  .option("--verbose", "Print out all test results")
  .option("--headless", "run tests without showing the browser")
  .parse(process.argv);

// 'Windows 10'

const windows = {
  chrome: {
    platform: "Windows 10",
    browser: "chrome",
    browserVersion: "latest",
  },
  firefox: {
    platform: "Windows 10",
    browser: "firefox",
    browserVersion: "latest",
  },
  edge: {
    platform: "Windows 10",
    browser: "MicrosoftEdge",
    browserVersion: "latest",
  },
  ie: {
    platform: "Windows 10",
    browser: "internet explorer",
    browserVersion: "latest",
  },
};

const all_windows = [
  windows.chrome,
  windows.firefox,
  windows.edge,
  // i.e. takes forever and seems to make selenium timeout :/
  // not really sure how to extend the timeout.
  // , windows.ie
];

// "macOS 10.14"
const osx = {
  chrome: {
    platform: "macOS 10.14",
    browser: "chrome",
    browserVersion: "latest",
  },
  firefox: {
    platform: "macOS 10.14",
    browser: "firefox",
    browserVersion: "latest",
  },
  safari: {
    platform: "macOS 10.14",
    browser: "safari",
    browserVersion: "latest",
  },
};

const all_osx = [osx.safari];

const all_browsers = all_windows.concat(all_osx);

function prepare_all_envs(config) {
  var envs = [];

  for (i = 0; i < all_browsers.length; i++) {
    envs.push({
      browser: all_browsers[i].browser,
      browserVersion: all_browsers[i].browserVersion,
      platform: all_browsers[i].platform,
      build: config.build,
      name: config.name,
    });
  }

  //   for (i = 0; i < osx.length; i++) {
  //     envs.push({
  //       browser: osx[i].browser,
  //       browserVersion: osx[i].browserVersion,
  //       platform: "macOS 10.14",
  //       build: config.build,
  //       name: config.name,
  //     });
  //   }

  return envs;
}

function prepare_sauce_driver(env) {
  const username = process.env.SAUCE_USERNAME;
  const accessKey = process.env.SAUCE_ACCESS_KEY;

  driver = new Builder()
    .withCapabilities({
      browserName: env.browser,
      platformName: env.platform,
      browserVersion: env.browserVersion,
      /* Pass Sauce User Name and Access Key */
      "sauce:options": {
        username: username,
        accessKey: accessKey,
        build: env.build,
        name: env.name,
      },
    })
    .usingServer("https://@ondemand.saucelabs.com:443/wd/hub")
    .build();

  return driver;
}

async function prepare_local_driver(env) {
  const firefoxOptions = new firefox.Options();
  const chromeOptions = new chrome.Options();

  if (program.headless) {
    firefoxOptions.headless();
    chromeOptions.headless();
  }

  let driver = await new Builder()
    .forBrowser(env.browser)
    .setChromeOptions(chromeOptions)
    .setFirefoxOptions(firefoxOptions)
    .build();

  return driver;
}

async function run_test(driver, url) {
  var results = null;
  try {
    await driver
      .manage()
      .window()
      .setRect({ width: 1200, height: 800, x: 0, y: 0 });
    await driver.get(url);
    await driver.wait(until.titleIs("tests finished"), 240 * 1000);
    results = await driver.executeScript("return test_results");
  } finally {
    await driver.quit();
  }
  return results;
}

(async () => {
  var dir = "tmp";
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir);
  }
  console.log("Compiling tests");
  await compile_and_embed({
    template: "./tests-rendering/automation/templates/gather-styles.html",
    target: "./tmp/test.html",
    elm: "src/Tests/All.elm",
    elmOptions: { cwd: "./tests-rendering" },
  });
  console.log("Done compiling");

  if (program.sauce) {
    const build = program.build;
    const name = program.name;

    if (build == null || name == null) {
      throw "A Build and a Name must be specified.";
    }

    var results = [];

    // Publish to netlify
    childProcess.execSync("sh tests-rendering/automation/publish-file.sh", {
      env: {
        FILE: "test.html",
        BUILD: program.build,
        NAME: program.name,
        GIT_EMAIL: "automation@elm-ui.com",
        GIT_NAME: "Elm UI Automation",
        HOME: process.env.HOME,
        SSH_AUTH_SOCK: process.env.SSH_AUTH_SOCK,
        SSH_AGENT_PID: process.env.SSH_AGENT_PID,
      },
    });

    var url = `http://elm-ui-testing.netlify.com/tests/${program.build}/${program.name}/`;
    console.log(`Running sauce labs test:`);
    console.log(`    ${url}`);

    const envs = prepare_all_envs({ build: build, name: name });
    console.log(envs);
    var test_runs = [];
    var test_labels = [];
    for (i = 0; i < envs.length; i++) {
      var driver = prepare_sauce_driver(envs[i]);
      test_runs.push(run_test(driver, url));
      test_labels.push(envs[i]);
    }
    var results = await Promise.all(test_runs);
    for (i = 0; i < results.length; i++) {
      print_results(renderEnvName(test_labels[i]), results[i]);
    }
  } else {
    // Run chrome if nothing else is selected
    if (program.chrome || (!program.chrome && !program.firefox)) {
      console.log("Running locally on Chrome...");
      const driver = await prepare_local_driver(osx.chrome);
      var results = await run_test(
        driver,
        "file://" + path.resolve("./tmp/test.html")
      );
      print_results("Local Chrome", results);
    }
    if (program.firefox) {
      console.log("Running locally on Firefox...");
      const driver = await prepare_local_driver(osx.firefox);
      var results = await run_test(
        driver,
        "file://" + path.resolve("./tmp/test.html")
      );
      print_results("Local Firefox", results);
    }
    if (program.ie) {
      console.log("Running locally on IE...");
      const driver = await prepare_local_driver(windows.ie);
      var results = await run_test(
        driver,
        "file://" + path.resolve("./tmp/test.html")
      );
      print_results("Local IE", results);
    }
    if (program.edge) {
      console.log("Running locally on Edge...");
      const driver = await prepare_local_driver(windows.edge);
      var results = await run_test(
        driver,
        "file://" + path.resolve("./tmp/test.html")
      );
      print_results("Local Edge", results);
    }
  }
})();

function renderEnvName(env) {
  return `${env.platform}, ${env.browser} ${env.browserVersion}`;
}

function print_results(label, tests) {
  var total_passed = 0;
  var total_failed = 0;
  var i;
  if (program.verbose) {
    console.log(label);
  }
  for (i = 0; i < tests.length; i++) {
    var passed = 0;
    var failed = 0;
    for (j = 0; j < tests[i].results.length; j++) {
      if (tests[i].results[j].passing) {
        passed = passed + 1;
      } else {
        if (failed == 0) {
          if (!program.verbose) {
            console.log(label);
          }
          console.log(tests[i].label);
        }
        failed = failed + 1;
        console.log("    " + chalk.red("fail") + " ->");
        console.log("        " + tests[i].results[j].description);
      }
    }
    total_passed = total_passed + passed;
    total_failed = total_failed + failed;

    if (failed != 0) {
      console.log(chalk.green(`    ${passed} tests passed`));
      console.log(chalk.red(`    ${failed} tests failed`));
      console.log();
    } else if (program.verbose) {
      console.log(tests[i].label + chalk.green(`    ${passed} tests passed`));
    }
  }
  if (total_failed == 0) {
    console.log(
      `${label} -> ` + chalk.green(`All ${total_passed} tests passed`)
    );
  }
}

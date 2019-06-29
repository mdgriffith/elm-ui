const path = require('path');

async function benchPage(page) {
    const client = await page.target().createCDPSession();
    await client.send('Performance.enable');
    // await page.tracing.start({ path: 'trace.json' });
    await page.goto(`file:${path.join(__dirname, '/../tmp/index.html')}`)

    await page.waitFor(1000);
    // await page.tracing.stop();
    const metrics = await client.send('Performance.getMetrics');
    await page.evaluate(() => { window.elmStartAnim() })
    await sleep(10000)
    await page.evaluate(() => { window.elmStopAnim() })
    const frames = await page.evaluate(x => {
        return Promise.resolve(window.metrics);
    }, {});

    return {
        name: frames.name,
        perf: extract(metrics),
        frames: summarize(frames.frames),
    }
}

function summarize(frames) {
    return {
        count: frames.length,
        median: median(frames),
        mode: mode(frames),
        avg: average(frames),
        fps: 1000 / average(frames)
    }
}

function extract(metrics) {
    var ext = {}
    metrics.metrics.forEach((item) => {
        ext[item.name] = item.value

    })
    ext.TimeToFirstPaintMS = 1000 * (ext.FirstMeaningfulPaint - ext.DomContentLoaded)
    return ext
}

function mode(array) {
    if (array.length == 0)
        return null;
    var modeMap = {};
    var maxEl = array[0], maxCount = 1;
    for (var i = 0; i < array.length; i++) {
        var el = array[i];
        if (modeMap[el] == null)
            modeMap[el] = 1;
        else
            modeMap[el]++;
        if (modeMap[el] > maxCount) {
            maxEl = el;
            maxCount = modeMap[el];
        }
    }
    return maxEl;
}

function average(values) {
    var total = 0;
    for (var i = 0; i < values.length; i++) {
        total += values[i];
    }
    return total / values.length;
}

function median(values) {
    if (values.length === 0) return 0;

    values.sort(function (a, b) {
        return a - b;
    });

    var half = Math.floor(values.length / 2);

    if (values.length % 2)
        return values[half];

    return (values[half - 1] + values[half]) / 2.0;
}


function sleep(ms) {
    return new Promise(resolve => {
        setTimeout(resolve, ms)
    })
}
module.exports = benchPage;
const path = require('path');

async function benchPage(page, file) {
    const client = await page.target().createCDPSession();
    await client.send('Performance.enable');
    // await page.tracing.start({ path: 'trace.json' });
    await page.goto('file://' + path.resolve(file))

    await page.waitFor(5000);
    // await page.tracing.stop();
    const metrics = await client.send('Performance.getMetrics');

    const startMetrics = await page.metrics()
    await page.evaluate(() => { window.elmRefresh() })
    await page.waitFor(1500);
    const endMetrics = await page.metrics()

    await page.evaluate(() => { window.elmStartAnim() })
    await sleep(5000)
    await page.evaluate(() => { window.elmStopAnim() })
    await page.waitFor(2000);
    const finalMetrics = await page.metrics()
    const frames = await page.evaluate(x => {
        return Promise.resolve(window.metrics);
    }, {});
    return {
        name: frames.name,
        link: 'file://' + path.resolve(file),
        perf: extract(metrics),
        afterRefresh: {
            RecalcStyleDuration: endMetrics.RecalcStyleDuration - startMetrics.RecalcStyleDuration,
            LayoutDuration: endMetrics.LayoutDuration - startMetrics.LayoutDuration,
            ScriptDuration: endMetrics.ScriptDuration - startMetrics.ScriptDuration,
            JSHeapUsedSize: endMetrics.JSHeapUsedSize - startMetrics.JSHeapUsedSize
        },
        afterAnimation: {
            RecalcStyleDuration: finalMetrics.RecalcStyleDuration - endMetrics.RecalcStyleDuration,
            LayoutDuration: finalMetrics.LayoutDuration - endMetrics.LayoutDuration,
            ScriptDuration: finalMetrics.ScriptDuration - endMetrics.ScriptDuration,
            JSHeapUsedSize: finalMetrics.JSHeapUsedSize - endMetrics.JSHeapUsedSize
        },
        frames: summarize(frames.frames),
    }
}

function summarize(frames) {
    return {
        count: frames.length,
        median: median(frames),
        mode: mode(frames),
        avg: average(frames),
        fps: 1000 / median(frames),
        min: minimum(frames),
        max: maximum(frames)
    }
}

const keep = ["Timestamp", "Nodes", "LayoutDuration", "RecalcStyleDuration", "ScriptDuration", "JSHeapUsedSize", "FirstMeaningfulPaint", "DomContentLoaded", "NavigationStart"]


function extract(metrics) {
    var ext = {}
    metrics.metrics.forEach((item) => {
        if (keep.indexOf(item.name) >= 0) {
            ext[item.name] = item.value
        }
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

function minimum(values) {
    var m = null
    for (var i = 0; i < values.length; i++) {
        if (m == null) {
            m = values[i]
        } else if (values[i] < m) {
            m = values[i]
        }
    }
    return m
}


function maximum(values) {
    var m = null
    for (var i = 0; i < values.length; i++) {
        if (m == null) {
            m = values[i]
        } else if (values[i] > m) {
            m = values[i]
        }
    }
    return m
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
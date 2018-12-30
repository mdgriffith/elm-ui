

import appium
import selenium
import selenium.webdriver.firefox.options
import os

browsers = {'Windows 10':
            {'internet explorer': ['11.285'], 'MicrosoftEdge': ['18.17763'], 'chrome': ['71.0'], 'firefox': ['64.0']
             },
            "macOS 10.14":
            {'chrome': ['71.0'], 'firefox': ['64.0'], 'safari': ['12.0']}

            }


def desktop():

    caps = []
    for platform, brows in browsers.items():
        for browser, versions in brows.items():
            for vers in versions:
                cap = {'platform': platform,
                       'browserName': browser, 'version': vers}

                caps.append(
                    {'driver_type': 'desktop',
                     'capabilities': cap})

    return caps


def local():
    options = selenium.webdriver.firefox.options.Options()
    options.set_headless(True)

    driver = selenium.webdriver.Firefox(options=options)
    caps = {}
    caps['browserName'] = "firefox"
    caps['platform'] = "macOS 10.14"
    return [{'driver_type': 'local', 'capabilities': caps}]


def mobile():

    caps = {}
    caps['browserName'] = "Safari"
    caps['appiumVersion'] = "1.9.1"
    caps['deviceName'] = "iPhone XS Simulator"
    caps['deviceOrientation'] = "portrait"
    caps['platformVersion'] = "12.0"
    caps['platformName'] = "iOS"
    return [{'capabilities': caps, 'driver_type': 'app'}]


def get_credentials():
    return {'username': os.environ['SAUCE_USERNAME'], 'access_key': os.environ['SAUCE_ACCESS_KEY']}


def start_driver(env, capabilities):
    if env == 'app':
        return app(capabilities)
    elif env == 'desktop':
        return remote(capabilities)
    else:
        options = selenium.webdriver.firefox.options.Options()
        options.set_headless(True)

        return selenium.webdriver.Firefox(options=options)


def remote(desired_cap):
    creds = get_credentials()
    driver = selenium.webdriver.Remote(
        command_executor='http://{username}:{key}@ondemand.saucelabs.com:80/wd/hub'.format(
            username=creds['username'],
            key=creds['access_key']),
        desired_capabilities=desired_cap)

    return driver


def app(desired_cap):
    creds = get_credentials()
    driver = appium.webdriver.Remote(
        command_executor='http://{username}:{key}@ondemand.saucelabs.com:80/wd/hub'.format(
            username=creds['username'],
            key=creds['access_key']),
        desired_capabilities=desired_cap)

    return driver

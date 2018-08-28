from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import os
import time


def browsers():

    capabilities = [
        {'platform': "Mac OS X 10.9",
         'browserName': "chrome",
         'version': "31",
         }
    ]
    return capabilies


def run_local():
    driver = webdriver.Firefox()
    local_file = "file://" + os.getcwd() + "/gather-styles.html"
    run_test(driver, local_file)


def get_credentials():
    return {'username': os.environ['SAUCE_USERNAME'], 'access_key': os.environ['SAUCE_ACCESS_KEY']}


def run_remote(desired_cap):
    creds = get_credentials()
    driver = webdriver.Remote(
        command_executor='http://{username}:{key}@ondemand.saucelabs.com:80/wd/hub'.format(
            username=creds['username'],
            key=creds['access_key']),
        desired_capabilities=desired_cap)
    run_test(driver)


def run_test(driver, url):
    try:
        driver.get(local_file)
        for x in range(5):
            results = driver.execute_script('return test_results')
            if results != "waiting..":
                print(results)
                break
            time.sleep(1)
    except Exception as inst:
        print(type(inst))
        print(inst.args)
        print(inst)
        driver.quit()
    else:
        print("quitting browser")
        driver.quit()


if __name__ == "__main__":
    run_local()

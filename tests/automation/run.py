import os
import time
import pprint
import json
import sys

import environments


def run(env, url):
    driver = environments.start_driver(env['driver_type'], env['capabilities'])

    test_run = run_test(driver, url)
    return {'capabilities': env['capabilities'], 'failures': test_run, 'success': test_run == []}


def log_results(all_results):

    for group in all_results:
        print(group["label"])
        all_pass = True
        for result in group["results"]:
            name = result[0]
            val = result[1]

            if val is not None:
                print("    Failed - " + name)
                all_pass = False
                # { given : Maybe String
                # , description : String
                # , reason : Failure.Reason
                # }
                pprint.pprint(val)

        if all_pass:
            print("   All passed!")


def only_failures(all_results):
    failures = []
    for group in all_results:

        for result in group["results"]:
            name = result[0]
            val = result[1]

            if val is not None:
                failures.append(
                    {'group': group['label'], 'description': name, 'result': val})

    return failures


def run_test(driver, url):
    print("Running test...")
    results = None
    try:
        # print("Opening Browser")
        driver.get(url)

        # print("Checking Results")
        time.sleep(20)
        for x in range(60):
            feedback = driver.execute_script('return test_results')
            if feedback != "waiting..":
                results = only_failures(feedback)
                # log_results(feedback)
                break
            time.sleep(1)
    except Exception as inst:
        print(type(inst))
        print(inst.args)
        print(inst)
        driver.quit()
    else:
        print("Finished!")
        driver.quit()

    return results


if __name__ == "__main__":

    url = "http://mdgriffith.github.io/elm-ui/tests/base/"

    results = []
    if len(sys.argv) > 1:
        if sys.argv[1] == "--local":
            envs = environments.local()
        else:
            raise "Unknown argument, run --local to run locally."
    else:
        envs = environments.desktop()
        envs.extend(environments.mobile())

    for env in envs:
        pprint.pprint(env['capabilities'])
        result = run(env, url)
        results.append(result)
        print("--")

    pprint.pprint(results)

    with open("automation/results/test-results.json", 'w') as RESULTS:
        RESULTS.write(json.dumps(results, indent=4))

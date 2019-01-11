compile:
	elm make Tests/Run.elm --output=elm.js

local_test:
	source env/bin/activate
	source sauce.env
	python3 automation/selenium_test.py --local

remote_test:
	source env/bin/activate
	source sauce.env
	python3 automation/run.py
	

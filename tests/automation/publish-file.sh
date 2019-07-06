DIRECTORY='./tmp/elm-ui-testing'

# Check to see if the repo is already cloned locally
# if [ ! -d "$DIRECTORY" ]; then
#   cd tmp  
#   git clone git@github.com:mdgriffith/elm-ui-testing.git
# else
#   cd tmp
#   git pull
# fi

cp test.html elm-ui-testing/public/tests/test.html
cd elm-ui-testing
git add .
git commit -m "Publish file from elm-ui suite"
git push origin master

echo "done"
These env variables need to be set before running this script
# FILE="test.html"
# BUILD="1.1.0"
# NAME="development"
DIRECTORY='./tmp/elm-ui-testing'

# Check to see if the repo is already cloned locally
cd tmp
if [ ! -d "$DIRECTORY" ]; then
  git clone git@github.com:mdgriffith/elm-ui-testing.git
else
  git pull
fi
mkdir -p "elm-ui-testing/public/tests/$BUILD/$NAME/"
cp "$FILE" "elm-ui-testing/public/tests/$BUILD/$NAME/index.html"
cd elm-ui-testing
git add .
git commit -m "Elm UI test for $NAME on $BUILD"
git push origin master

echo "done"
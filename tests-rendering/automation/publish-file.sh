# These env variables need to be set before running this script
# FILE="test.html"
# BUILD="1.1.0"
# NAME="development"
DIRECTORY='elm-ui-testing'

# Check to see if the repo is already cloned locally
cd tmp
if [ ! -d "$DIRECTORY" ]; then
  git clone git@github.com:mdgriffith/elm-ui-testing.git
else
  git pull
fi
mkdir -p "$DIRECTORY/public/tests/$BUILD/$NAME/"
cp "$FILE" "$DIRECTORY/public/tests/$BUILD/$NAME/index.html"
if [ -z "$(git status --porcelain)" ]; then 
  # Working directory clean
  echo "No changes need for $BUILD -> $NAME"
else 
  cd "$DIRECTORY"
  # Uncommitted changes
  git add .
  git commit -m "Elm UI test for $NAME on $BUILD"
  git push origin master

  echo "Files published for for $BUILD -> $NAME"
fi



STORY_CACHE=~/.lobsters_stories
STORY_FILE=~/.lobsters_stories/news

if [ ! -d "$STORY_CACHE" ]; then
  mkdir -v $STORY_CACHE
  touch $STORY_FILE
fi

if [ ! "$(find "$STORY_CACHE" -mmin -15)" ]; then
    perl ~/bin/headlines.pl > $STORY_FILE
    cat $STORY_FILE
else
    cat $STORY_FILE
fi

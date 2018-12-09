#!/bin/sh -l

if [ -f "$HOME/ignore" ] && grep "^ignore:$BUILD_DIR" "$HOME/ignore"; then
  echo "$BUILD_DIR didn't change"
else
  echo "Deploying"
  echo "Sending build request"
  code=$(curl \
    --silent \
    --show-error \
    --output /dev/stderr \
    --write-out "%{http_code}" \
    -H 'Content-Type: application/json' \
    -X POST -d '{}' \
    "$NETLIFY_HOOK"
  ) 2>&1
  echo "Status code $code"
  if [ ! 204 -eq "$code" ] && [ ! 200 -eq "$code" ]; then
    exit 1
  fi
fi

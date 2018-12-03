#!/bin/sh -l

if [ -f "$HOME/ignore" ] && grep "^ignore:$BUILD_DIR" "$HOME/ignore"; then
  echo "$BUILD_DIR didn't change"
else
  echo "Deploying"
  echo "Creating args.json"
  jq \
    --arg cmd "$NETLIFY_CMD" \
    --arg base "$NETLIFY_BASE" \
    --arg dir "$NETLIFY_DIR" \
    --arg site_id "$NETLIFY_SITE_ID" \
    '. + {cmd: $cmd, base: $base, dir: $dir, site_id: $site_id}' \
     "$GITHUB_EVENT_PATH" > args.json
  echo "Created args.json"
  echo "Sending build request"
  code=$(curl \
    --silent \
    --show-error \
    --output /dev/stderr \
    --write-out "%{http_code}" \
    -H "Authorization: $GITHUB_TOKEN" \
    -H "X-GitHub-Event: $GITHUB_EVENT_TYPE" \
    -H 'Content-Type: application/json' \
    --data-binary @args.json \
    "https://api.netlify.com/api/v1/github/$GITHUB_REPOSITORY/build"
  ) 2>&1
  
  echo "Status code $code"
  if [ ! 204 -eq "$code" ] && [ ! 200 -eq "$code" ]; then
    exit 1
  fi
fi

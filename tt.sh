#!/usr/bin/env sh
# First 2 chars in the file are called Shebang https://en.wikipedia.org/wiki/Shebang_%28Unix%29
# In this case:
#   Execute this file with a "sh" interpreter, using the "env" program search path to find it.
# Now you know!

function tt() {
  # :- means that if TT_LOG doesn't exit, it will assign $HOME/.tt_log (~/.tt_log)
  TT_LOG="${TT_LOG:-./.tt_log}"
  TT_SESSION="${TT_SESSION:-./.tt_session}"

  echo "Hi $TT_LOG"

  if [ -f "$TT_SESSION" ]; then
    echo "$TT_SESSION exists."
  else
    touch $TT_SESSION
  fi

  local timestamp=$(date +%s)

  echo "session=${timestamp}" >$TT_SESSION

  sleep 2

  echo "$(date)" >>$TT_SESSION
  echo "$(date -r $timestamp)" >>$TT_SESSION

  # Do we have an activity active for this session?
  local match
  match=$(grep 'session=' "$TT_SESSION" | sed -E "s/.*session=([0-9]+).*/\\1/")

  local new_timestamp=$(date +%s)
  local sec_diff=$(($new_timestamp - $match))

  local sec_in_hour=3600

  local diff=$(bc <<< "scale=2; $sec_diff / $sec_in_hour")

  echo "$diff"
}

#!/usr/bin/env sh
# First 2 chars in the file are called Shebang https://en.wikipedia.org/wiki/Shebang_%28Unix%29
# In this case:
#   Execute this file with a "sh" interpreter, using the "env" program search path to find it.
# Now you know!

tt() {
  # :- means that if TT_LOGS doesn't exit, it will assign $HOME/.tt_log (~/.tt_log)
  TT_LOGS="${TT_LOGS:-$HOME/.tt_logs}"
  TT_SESSION="${TT_SESSION:-$HOME/.tt_session}"
  if ! [ -f "$TT_SESSION" ]; then
    touch "$TT_SESSION"
  fi
  if ! [ -f "$TT_LOGS" ]; then
    echo "UTC,activity name,human time spent,total seconds" >"$TT_LOGS"
  fi
  # See end of function for starting of _options

  # Internal functions
  _options() {
    echo ""
    case "$1" in
    --activity-name)
      # Shows the current activity name if there is one for this session
      activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
      if [ -z "${activity_name}" ]; then
        echo "No activity started"
      else
        echo "Activity '$activity_name'"
      fi
      ;;
    -h | --help)
      # Help
      echo "tt - time tracker"
      echo ""
      echo "Tracks activity time with a simple start/stop syntax. Logs to CSV."
      echo "Allows one activity active at a time, per session."
      echo ""
      echo "usage: tt                                       # show this help"
      echo "usage: tt (--help or -h)                        # show this help"
      echo "usage: tt (--start or -s) [activity name]       # start a new activity"
      echo "usage: tt (--pause or -p)                       # pauses current activity"
      echo "usage: tt (--done or -d or --finish or -f)      # stop and log activity"
      echo "usage: tt (--abort or -a)                       # stop activity, no log"
      echo "usage: tt --clear-logs                          # delete log of previous activities"
      echo "usage: tt --activity-name                       # show activity for current session"
      echo "usage: tt (--logs or -l)                        # show logs of previous activities"
      ;;
    -p | --pause)
      _pause
      ;;
    -d | --done | -f | --finish)
      _finish
      ;;
    -a | --abort)
      echo "Abort activity"
      echo "" >"$TT_SESSION"
      crontab -r
      ;;
    -l | --logs)
      cat "$TT_LOGS"
      ;;
    --clear-logs)
      echo "Logs cleared"
      echo "UTC,activity name,human time spent,total seconds" >"$TT_LOGS"
      ;;
    -s | --start)
      _start "$2"
      ;;

    *)
      echo "!!!! Invalid option !!!!"
      _options -h
      ;;
    esac
  }

  _start() {
    start_timestamp=$(date +%s)
    # No activity name passed
    if [ -z "$1" ]; then
      activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
      if [ -z "$activity_name" ]; then
        echo "No activity started"
        return
      else
        echo "Restarting '$activity_name'"
        elapsed_sec=$(grep 'elapsed_sec=' "$TT_SESSION" | sed -E "s/.*elapsed_sec=([0-9]+).*/\\1/")
        echo "start_time=${start_timestamp}" >"$TT_SESSION"
        echo "elapsed_sec=${elapsed_sec}" >>"$TT_SESSION"
        echo "activity_name=${activity_name}" >>"$TT_SESSION"
        # runs on MacOS
        if [ "$(uname)" = "Darwin" ]; then
          (printf '*/15 * * * * say "Activity from tt is active!"\n') | crontab
        fi
      fi
      return
    fi
    # finish old activity if exists
    old_activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
    if [ -n "$old_activity_name" ]; then
      _finish
    fi
    echo "Starting '$1'"
    echo "start_time=${start_timestamp}" >"$TT_SESSION"
    echo "elapsed_sec=0" >>"$TT_SESSION"
    echo "activity_name=$1" >>"$TT_SESSION"
    # runs on MacOS
    if [ "$(uname)" = "Darwin" ]; then
      (printf '*/15 * * * * say "Activity from tt is active!"\n') | crontab
    fi
  }

  _pause() {
    # Do we have an activity active for this session?
    start_time=$(grep 'start_time=' "$TT_SESSION" | sed -E "s/.*start_time=([0-9]+).*/\\1/")
    elapsed_sec=$(grep 'elapsed_sec=' "$TT_SESSION" | sed -E "s/.*elapsed_sec=([0-9]+).*/\\1/")
    activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
    if [ -z "$start_time" ]; then
      echo "No activity started"
      return
    fi
    if [ "$start_time" = "0" ]; then
      echo "Activity '$activity_name' is already paused"
      return
    fi
    pause_timestamp=$(date +%s)
    sec_diff=$((pause_timestamp - start_time + elapsed_sec))
    hours=$((sec_diff / 3600))
    mins=$(((sec_diff - (hours * 3600)) / 60))
    echo "start_time=0" >"$TT_SESSION"
    echo "elapsed_sec=${sec_diff}" >>"$TT_SESSION"
    echo "activity_name=${activity_name}" >>"$TT_SESSION"
    echo "Activity '$activity_name' paused at ${hours}h ${mins}m"
    # runs on MacOS
    if [ "$(uname)" = "Darwin" ]; then
      (printf '* * * * * say "Activity from tt is paused!"\n') | crontab
    fi
  }

  _finish() {
    # Do we have an activity active for this session?
    start_time=$(grep 'start_time=' "$TT_SESSION" | sed -E "s/.*start_time=([0-9]+).*/\\1/")
    elapsed_sec=$(grep 'elapsed_sec=' "$TT_SESSION" | sed -E "s/.*elapsed_sec=([0-9]+).*/\\1/")
    activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
    if [ -z "$activity_name" ]; then
      echo "No activity started"
      return
    fi
    # Activity was paused
    if [ "$start_time" = "0" ]; then
      _save "$activity_name" "$elapsed_sec"
      echo "" >"$TT_SESSION"
      crontab -r
      return
    fi
    finish_timestamp=$(date +%s)
    sec_diff=$((finish_timestamp - start_time + elapsed_sec))
    _save "$activity_name" $sec_diff
    echo "" >"$TT_SESSION"
    crontab -r
  }

  _save() {
    activity_name=$1
    sec_diff=$2
    hours=$((sec_diff / 3600))
    mins=$(((sec_diff - (hours * 3600)) / 60))
    utc_date=$(date -u)
    echo "$utc_date | $activity_name | ${hours}h ${mins}m"
    log="$utc_date,$activity_name,${hours}h ${mins}m,$sec_diff"
    echo "$log" >>"$TT_LOGS"
  }

  # Parse params
  if [ $# -eq 0 ]; then
    # No parameters = show help
    _options -h
  else
    _options "$1" "$2"
  fi
}

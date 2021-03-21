#!/usr/bin/env sh
# First 2 chars in the file are called Shebang https://en.wikipedia.org/wiki/Shebang_%28Unix%29
# In this case:
#   Execute this file with a "sh" interpreter, using the "env" program search path to find it.
# Now you know!

function _start() {
  local start_timestamp=$(date +%s)

  # No activity name passed
  if [ -z $1 ]; then
    local activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
    if [ -z $activity_name ]; then
      echo "No activity started"
      return
    else
      echo "Restarting '$activity_name'"

      local elapsed_sec=$(grep 'elapsed_sec=' "$TT_SESSION" | sed -E "s/.*elapsed_sec=([0-9]+).*/\\1/")
      echo "start_time=${start_timestamp}" >$TT_SESSION
      echo "elapsed_sec=${elapsed_sec}" >>$TT_SESSION
      echo "activity_name=${activity_name}" >>$TT_SESSION
    fi
    return
  fi

  # finish old activity if exists
  local old_activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
  if ! [ -z $old_activity_name ]; then
    _finish
  fi

  echo "Starting '$1'"

  echo "start_time=${start_timestamp}" >$TT_SESSION
  echo "elapsed_sec=0" >>$TT_SESSION
  echo "activity_name=$1" >>$TT_SESSION
}

function _pause() {
  # Do we have an activity active for this session?
  local start_time=$(grep 'start_time=' "$TT_SESSION" | sed -E "s/.*start_time=([0-9]+).*/\\1/")
  local elapsed_sec=$(grep 'elapsed_sec=' "$TT_SESSION" | sed -E "s/.*elapsed_sec=([0-9]+).*/\\1/")
  local activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")

  if [ -z ${start_time} ]; then
    echo "No activity started"
    return
  fi

  if [[ "$start_time" == "0" ]]; then
    echo "Activity '$activity_name' is already paused"
    return
  fi

  local pause_timestamp=$(date +%s)

  local sec_diff=$(($pause_timestamp - $start_time + $elapsed_sec))

  echo "start_time=0" >$TT_SESSION
  echo "elapsed_sec=${sec_diff}" >>$TT_SESSION
  echo "activity_name=${activity_name}" >>$TT_SESSION

  echo "Activity '$activity_name' paused"
}

function _save() {
  local activity_name=$1
  local sec_diff=$2
  local hours=$(($sec_diff / 3600))
  local mins=$((($sec_diff - ($hours * 3600)) / 60))

  local utc_date=$(date -u)

  echo "$utc_date | $activity_name | ${hours}h ${mins}m"
  local log="$utc_date,$activity_name,${hours}h ${mins}m"
  echo "$log" >>$TT_LOGS
}

function _finish() {
  # Do we have an activity active for this session?
  local start_time=$(grep 'start_time=' "$TT_SESSION" | sed -E "s/.*start_time=([0-9]+).*/\\1/")
  local elapsed_sec=$(grep 'elapsed_sec=' "$TT_SESSION" | sed -E "s/.*elapsed_sec=([0-9]+).*/\\1/")
  local activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")

  if [ -z ${activity_name} ]; then
    echo "No activity started"
    return
  fi

  # Activity was paused
  if [[ "$start_time" == "0" ]]; then
    _save $activity_name $elapsed_sec
    echo "" >$TT_SESSION
    return
  fi

  local finish_timestamp=$(date +%s)
  local sec_diff=$(($finish_timestamp - $start_time + $elapsed_sec))

  _save $activity_name $sec_diff
  echo "" >$TT_SESSION
}

function tt() {
  # :- means that if TT_LOGS doesn't exit, it will assign $HOME/.tt_log (~/.tt_log)
  TT_LOGS="${TT_LOGS:-$HOME/.tt_logs}"
  TT_SESSION="${TT_SESSION:-$HOME/.tt_session}"

  if ! [ -f "$TT_SESSION" ]; then
    touch $TT_SESSION
  fi
  if ! [ -f "$TT_LOGS" ]; then
    echo "UTC,activity name,time spent" >$TT_LOGS
  fi

  echo ""

  if [ $# -eq 0 ]; then
    # No parameters = show help
    _options -h
  else
    _options $1 $2
  fi
}

function _options() {
  case "$1" in

  --activity-name)
    # Shows the current activity name if there is one for this session
    local activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")
    if [ -z ${activity_name} ]; then
      echo "No activity started"
    else
      echo $activity_name
    fi
    ;;

  -h | --help)
    # Help
    echo "tt - time tracker"
    echo " "
    echo "Tracks activity time with a simple start/stop syntax. Logs to CSV."
    echo "Allows one activity active at a time, per session."
    echo " "
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
    echo "" >$TT_SESSION
    ;;

  -l | --logs)
    cat $TT_LOGS
    ;;

  --clear-logs)
    echo "Logs cleared"
    echo "UTC,activity name,time spent" >$TT_LOGS
    ;;

  -s | --start)
    _start $2
    ;;

  *)
    echo "!!!! Invalid option !!!!"
    echo ""
    _options -h
    ;;

  esac
}

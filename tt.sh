#!/usr/bin/env sh
# First 2 chars in the file are called Shebang https://en.wikipedia.org/wiki/Shebang_%28Unix%29
# In this case:
#   Execute this file with a "sh" interpreter, using the "env" program search path to find it.
# Now you know!

function _start() {
  local start_timestamp=$(date +%s)
  echo "start_time=${start_timestamp}" >$TT_SESSION
  echo "elapsed_sec=4000" >>$TT_SESSION
  echo "activity_name=$1" >>$TT_SESSION
}

function _finish() {
  # Do we have an activity active for this session?
  local start_time=$(grep 'start_time=' "$TT_SESSION" | sed -E "s/.*start_time=([0-9]+).*/\\1/")
  local elapsed_sec=$(grep 'elapsed_sec=' "$TT_SESSION" | sed -E "s/.*elapsed_sec=([0-9]+).*/\\1/")
  local activity_name=$(grep 'activity_name=' "$TT_SESSION" | sed -E "s/.*activity_name=(.+)$.*/\\1/")

  if [ -z ${start_time} ]; then
    echo "No activity started"
    return
  fi

  local finish_timestamp=$(date +%s)
  local sec_diff=$(($finish_timestamp - $start_time))

  local sec_in_hour=3600
  local hour_diff=$(bc <<<"scale=2; $sec_diff / $sec_in_hour")

  echo "$sec_diff, $hour_diff"
  echo "$start_time, $elapsed_sec, $activity_name"

  echo "" >$TT_SESSION
}

function tt() {
  # :- means that if TT_LOG doesn't exit, it will assign $HOME/.tt_log (~/.tt_log)
  TT_LOG="${TT_LOG:-./.tt_log}"
  TT_SESSION="${TT_SESSION:-./.tt_session}"

  if ! [ -f "$TT_SESSION" ]; then
    touch $TT_SESSION
  fi

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

  --shortlist)
    # Shows a short list of commands without context
    echo "--help --start --done --finish --abort --list --clear-log --activity-name --shortlist"
    ;;

  -h | --help)
    # Help
    echo "tt - time tracker"
    echo " "
    echo "Tracks activity time with a simple start/stop syntax. Logs to CSV. Tmux session aware."
    echo "Allows one activity active at a time, per session."
    echo " "
    echo "usage: tt                                       # show this help"
    echo "usage: tt (--help or -h)                        # show this help"
    echo "usage: tt (--start or -s) [activity name]       # start a new activity"
    echo "usage: tt (--done or -d or --finish or -f)      # stop and log activity"
    echo "usage: tt (--abort or -a)                       # stop activity, no log"
    echo "usage: tt --clear-log                           # delete log of previous activities"
    echo "usage: tt --activity-name                       # show activity for current session"
    echo "usage: tt --shortlist                           # quick list of commands without context"
    echo "usage: tt [activity name]                       # toggles start/stop"
    echo "usage: tt (--list -l) [options]                 # show log of previous activities"
    echo "    option: t                                   # summarize time by activity"
    echo "    option: s                                   # show only current session"
    ;;

  -d | --done | -f | --finish)
    _finish
    ;;

  \
    -a | --abort) ;;

  \
    -l | --log) ;;

  \
    --clear-log)
    # Empty contents of log
    >"$TIME_LOG"
    ;;

  * | -s | --start)
    if [ $# -eq 1 ]; then
      echo "Please provide activity name"
    else
      _start $2
    fi
    ;;
  esac
}

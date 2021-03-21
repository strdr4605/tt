# tt

Command line time tracker written in shell script

## Usage

### Start the activity

```bash
tt --start "working on this timer"

Starting 'working on this timer'
```

### Finish the activity

```bash
tt --finish

Sun Mar 21 00:38:10 UTC 2021 | working on this timer | 11h 25m
```

### Options

```text
tt

tt - time tracker

Tracks activity time with a simple start/stop syntax. Logs to CSV.
Allows one activity active at a time, per session.

usage: tt                                       # show this help
usage: tt (--help or -h)                        # show this help
usage: tt (--start or -s) [activity name]       # start a new activity
usage: tt (--pause or -p)                       # pauses current activity
usage: tt (--done or -d or --finish or -f)      # stop and log activity
usage: tt (--abort or -a)                       # stop activity, no log
usage: tt --clear-logs                          # delete log of previous activities
usage: tt --activity-name                       # show activity for current session
usage: tt (--logs or -l)                        # show logs of previous activities
```

## Installation

### Download

```bash
curl https://raw.githubusercontent.com/strdr4605/tt/master/tt.sh > $HOME/tt.sh
```

### Source in your shell config file
```bash
# ZSH
echo "source $HOME/tt.sh" >>$HOME/.zshrc

# BASH
echo "source $HOME/tt.sh" >>$HOME/.bash_profile
```

## Development

1. Change `tt.sh`
2. `source ./tt.sh`
3. `tt`

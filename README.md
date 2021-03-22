# tt [![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fstrdr4605%2Ftt&count_bg=%2379C83D&title_bg=%2379C83D&icon=powershell.svg&icon_color=%23E7E7E7&title=tt&edge_flat=false)](https://hits.seeyoufarm.com) [![Hits-of-Code](https://hitsofcode.com/github/strdr4605/tt?branch=master)](https://hitsofcode.com/github/strdr4605/tt/view?branch=master)

Command line time tracker written in shell script

[Why? How?](https://strdr4605.github.io/building-a-command-line-time-tracker)

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

1. Change `tt.sh` (use [shellcheck](https://www.shellcheck.net))
2. `source ./tt.sh`
3. `tt`

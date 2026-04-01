# Goblin Mode

Claude Code goes goblin mode. Autonomous server management powered by Claude, with a TUI or headless operation.

Point it at a server, pick a mode, set the chaos level, and let Claude loose. It assesses, implements, tests, and documents changes in a continuous loop — each iteration only advances after the previous one is validated and working.

## Quick Start

```bash
# TUI — configure settings then press 'g' to go
./goblin

# Headless — straight to work
./goblin -H -m mayhem

# Dry run — see what it would do without changing anything
./goblin -H -m harden -d

# Full send
./goblin --go -m mayhem -C 5
```

## Requirements

- bash 4+
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (`claude`)

Optional: `./claude-sudo.sh on` to grant passwordless sudo for common system commands (apt, systemctl, ufw, docker, etc).

## Modes

| Mode | What it does |
|------|-------------|
| `optimise` | Performance tuning — CPU, memory, disk, network, remove bloat |
| `improve` | General best practices — updates, config fixes, quality of life |
| `install` | Discover and install useful services — monitoring, backups, security |
| `harden` | Security hardening — firewall, SSH, intrusion detection, permissions |
| `mayhem` | All of the above. Claude picks whatever is most impactful |

## Options

```
-m, --mode MODE       optimise | improve | install | harden | mayhem (default)
-M, --model MODEL     opus | sonnet | haiku | full model ID
-r, --request TEXT    Steer towards a specific area
-v, --verbose         Stream Claude output in real-time
-H, --headless        Skip TUI, plain terminal output
-d, --dry-run         Assess only, don't make changes
-l, --log-dir PATH    Log directory (default: ~/goblin-logs)
-C, --chaos 1-5       Aggression level (default: 3)
    --go              Skip settings screen, start immediately
```

## TUI

The TUI has two screens:

**Settings** — configure everything before starting. Arrow keys to navigate, Enter to cycle/edit values, `g` to go.

```
┌──────────────────────────────────────────────────┐
│ GOBLIN MODE settings                             │
├──────────────────────────────────────────────────┤
│                                                  │
│  > mode       mayhem                             │
│    model      opus                               │
│    request    (none)                              │
│    verbose    false                               │
│    dry-run    false                               │
│    chaos      3                                   │
│    log-dir    ~/goblin-logs                       │
│                                                  │
├──────────────────────────────────────────────────┤
│  go  quit  save  arrows+enter to edit            │
└──────────────────────────────────────────────────┘
```

**Running** — live status and history. Press `p` to pause, `s` to go back to settings, `q` to quit.

```
┌──────────────────────────────────────────────────────────────────────┐
│ GOBLIN MODE running                                                  │
│ mode:mayhem model:opus chaos:3 iter:3                                │
├──────────────────────────────────────────────────────────────────────┤
│ > Task: Installed and configured fail2ban                            │
│ > Result: success                                                    │
│ > Validated: service active, test ban triggered and released         │
│ > Usage: sudo fail2ban-client status | journalctl -u fail2ban        │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│ HISTORY                                                              │
│ OK  1. Enabled UFW firewall                                          │
│     Validated: ufw status shows active with default deny             │
│     Usage: sudo ufw status | sudo ufw allow <port>                   │
│ OK  2. Configured automatic security updates                         │
│     Validated: unattended-upgrades dry run succeeded                 │
│     Usage: cat /etc/apt/apt.conf.d/50unattended-upgrades             │
│ OK  3. Installed and configured fail2ban                             │
│     Validated: service active, test ban triggered and released       │
│     Usage: sudo fail2ban-client status | journalctl -u fail2ban      │
├──────────────────────────────────────────────────────────────────────┤
│ quit  pause  settings                                                │
└──────────────────────────────────────────────────────────────────────┘
```

## How It Works

Each iteration follows a strict protocol:

1. **Assess** the current system state
2. **Pick** one high-priority task
3. **Implement** it
4. **Test** that it actually works (service checks, endpoint curls, smoke tests)
5. **Rollback** if tests fail
6. **Document** what was done, how to use it, and what the user needs to know

Iterations are achievement-based, not time-based. The next one starts immediately after the previous one completes successfully. No timers, no cooldowns.

Every iteration outputs a structured summary:

```
TASK:       what was done
RESULT:     success | partial | failure
VALIDATION: how it was tested
USAGE:      commands, URLs, config paths for the user
NOTES:      passwords, ports, breaking changes
NEXT:       what to tackle next
```

## Chaos Levels

| Level | Behavior |
|-------|----------|
| 1 | Extremely conservative. Minimal, low-risk changes only |
| 2 | Somewhat conservative. Small improvements |
| 3 | Balanced. Meaningful improvements, test everything |
| 4 | Aggressive. Significant changes, new services |
| 5 | Maximum chaos. Overhaul subsystems |

## Config

Settings persist in `~/.goblinrc` (press `s` in the TUI settings screen to save):

```
mode=mayhem
model=opus
verbose=true
chaos=4
```

CLI flags override config file values.

## Logs

All output is logged to `~/goblin-logs/` (or custom path with `--log-dir`):

| File | Contents |
|------|----------|
| `history.md` | Running summary of all iterations with results |
| `iteration-N-raw.log` | Full Claude output for iteration N |
| `goblin.log` | Timestamped event log |

## Sudo Helper

`claude-sudo.sh` manages passwordless sudo for a whitelist of system commands:

```bash
./claude-sudo.sh on       # enable whitelisted commands
./claude-sudo.sh off      # revoke access
./claude-sudo.sh status   # show current whitelist
./claude-sudo.sh add /usr/bin/something    # add a command
./claude-sudo.sh remove /usr/bin/something # remove a command
```

Default whitelist: apt, dpkg, snap, systemctl, journalctl, ufw, tee, cp, mv, mkdir, chmod, chown, docker, nginx, apachectl.

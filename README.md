
# Goblin Mode

Claude Code goes goblin mode. Autonomous server management — point it at your box, pick a mode, set the chaos level, and let Claude loose.

It assesses, implements, tests, and documents changes in a continuous loop. Each iteration only moves forward once the previous one is validated and working. Or it breaks something. That's kind of the point.

---

> **⚠️ WARNING: This tool runs Claude Code with `--dangerously-skip-permissions` and can make real, unsupervised changes to your system.**
>
> It will install packages, modify configs, restart services, and do other things you might not expect. Don't run this on anything you care about without understanding what it does. Don't run it on production. Don't come crying to us. You were warned.
>
> Use `--dry-run` if you want to see what it would do first. Use chaos level 1 if you're nervous. Or just let it rip — up to you.

---

## Quick Start

```bash
# TUI — configure settings then press 'g' to go
./goblin

# Headless — straight to work
./goblin -H -m mayhem

# Dry run — see what it would do without breaking anything
./goblin -H -m harden -d

# Full send, no brakes
./goblin --go -m mayhem -C 5
```

## Requirements

- bash 4+
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (`claude`)

## Modes

Modes are defined in `modes.conf` — you can edit them or add your own. Each mode is just a prompt that tells Claude what to focus on.

| Mode | What it does |
|------|-------------|
| `improve` | General best practices — updates, config fixes, performance tuning, removing bloat |
| `install` | Discover and install useful services — monitoring, backups, security tools, fun stuff |
| `mayhem` | Complete freedom. Claude picks whatever it thinks is most impactful. Goes hard. |

### Custom Modes

Add your own in `modes.conf`:

```ini
[mymode]
prompt = Focus on setting up a personal dev environment. Install neovim, tmux, zsh
         with sensible defaults. Make the box feel like home.
```

Then use it with `-m mymode`. That's it.

You can also point goblin at a different modes file entirely:

```bash
MODES_FILE=~/my-modes.conf ./goblin
```

## Options

```
-m, --mode MODE       improve | install | mayhem | (custom) (default: mayhem)
-M, --model MODEL     opus | sonnet | haiku | full model ID
-r, --request TEXT    Steer Claude towards something specific
-v, --verbose         Stream Claude output live in the status area
-H, --headless        Skip the TUI, plain terminal output
-d, --dry-run         Assess only, no changes made
-l, --log-dir PATH    Log directory (default: ~/goblin-logs)
-C, --chaos 1-5       Aggression level (default: 3)
    --go              Skip settings screen, start immediately
    --sudo ACTION     Manage sudo access: on | off | status
```

## Sudo Helper

By default Claude has to confirm before running privileged commands, which means it'll get stuck. `claude-sudo.sh` fixes that by granting passwordless sudo for a whitelist of safe-ish system commands.

```bash
./goblin --sudo on      # enable (prompts for confirmation)
./goblin --sudo off     # revoke
./goblin --sudo status  # show current whitelist

# Or use the script directly for more control:
./claude-sudo.sh add /usr/bin/something
./claude-sudo.sh remove /usr/bin/something
```

Default whitelist: `apt`, `dpkg`, `snap`, `systemctl`, `journalctl`, `ufw`, `tee`, `cp`, `mv`, `mkdir`, `chmod`, `chown`, `docker`, `docker-compose`, `nginx`, `apachectl`.

This writes to `/etc/sudoers.d/claude-automate`. Run `--sudo off` to clean it up.

## TUI

Two screens:

**Settings** — configure everything before starting. Arrow keys to navigate, Enter to cycle/edit, `g` to go.

```
┌──────────────────────────────────────────────────┐
│ GOBLIN MODE settings                             │
├──────────────────────────────────────────────────┤
│                                                  │
│  > mode       mayhem                             │
│    model      opus                               │
│    request    (none)                             │
│    verbose    false                              │
│    dry-run    false                              │
│    chaos      3 balanced                         │
│    log-dir    ~/goblin-logs                      │
│                                                  │
├──────────────────────────────────────────────────┤
│  go  quit  save  enter=edit arrows=nav           │
└──────────────────────────────────────────────────┘
```

**Running** — live status and iteration history. `p` to pause, `s` back to settings, `q` to quit.

```
┌──────────────────────────────────────────────────────────────────────┐
│ GOBLIN MODE running                                                  │
│ mode:mayhem model:opus chaos:3 balanced iter:3                       │
├──────────────────────────────────────────────────────────────────────┤
│ > Task: Installed and configured fail2ban                            │
│ > Result: success                                                    │
│ > Validated: service active, test ban triggered and released         │
│ > Usage: sudo fail2ban-client status                                 │
├──────────────────────────────────────────────────────────────────────┤
│ HISTORY                                                              │
│ OK  1. Enabled UFW firewall                                          │
│     Validated: ufw status shows active with default deny             │
│ OK  2. Configured automatic security updates                         │
│     Validated: unattended-upgrades dry run succeeded                 │
│ OK  3. Installed and configured fail2ban                             │
│     Validated: service active, test ban triggered and released       │
├──────────────────────────────────────────────────────────────────────┤
│ quit  pause  settings                                                │
└──────────────────────────────────────────────────────────────────────┘
```

Enable `--verbose` to see Claude's output streaming live in the status area.

## How It Works

Each iteration:

1. **Assess** the current system state
2. **Pick** one high-priority task
3. **Implement** it
4. **Test** that it actually works — service checks, endpoint curls, smoke tests
5. **Rollback** if something broke
6. **Document** what was done, how to use it, anything the user needs to know

The next iteration starts immediately after the previous one completes. No timers, no waiting around.

Every iteration logs a structured summary:

```
TASK:       what was done
RESULT:     success | partial | failure
VALIDATION: how it was tested and what passed
USAGE:      commands, URLs, config paths
NOTES:      passwords, ports, breaking changes (or 'none')
NEXT:       what to do next iteration
```

## Chaos Levels

| Level | Vibe |
|-------|------|
| 1 coward | Minimal changes, maximum caution. Almost nothing will go wrong |
| 2 careful | Small improvements only. Pretty safe |
| 3 balanced | Meaningful changes, everything gets tested. The default |
| 4 unhinged | Significant changes, new services, go for it |
| 5 GOBLIN | Overhaul subsystems. Anything goes. Good luck |

## Config

Settings persist in `~/.goblinrc` (press `s` in the settings screen to save):

```ini
mode=mayhem
model=opus
verbose=true
chaos=4
```

CLI flags override config file values.

## Logs

Everything gets logged to `~/goblin-logs/` (or `--log-dir` path):

| File | Contents |
|------|----------|
| `history.md` | Running summary of all iterations |
| `iteration-N-raw.log` | Full Claude output for iteration N |
| `goblin.log` | Timestamped event log |

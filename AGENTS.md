This is the `AGENTS.md` for the dotfiles repo.
This is not the `AGENTS.md` the setup script should set in `$HOME`.
The latter is located in `./agents/AGENTS.md`.

## Skills

Cross-agent skills live in `agents/skills/<skill-name>/`; Claude-only ones in `claude/skills/<skill-name>/`.
An agent can only reach a skill once `setup.sh` has symlinked it into `~/.agents/skills` and `~/.claude/skills`.

After adding, renaming, or removing a skill, run:

```sh
./setup.sh --links-only
```

`scripts/dotfiles-doctor` reports any symlink that drifted from `lib/links.sh`, so run it when a skill an agent should have is not showing up.

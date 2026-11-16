# vast.ai workflow

How I connect to vast.ai instances and give them GitHub access without
hardcoding addresses or forwarding my SSH agent to rented machines.

Code: [`modules/home-manager/vast`](../modules/home-manager/vast/), enabled
with `tilde.vast.enable = true;` (currently on **ctesiphon**).

## TL;DR

```sh
vastai tfa login --method-type totp -c <CODE>   # only if the 2FA session expired
vastutils sync                                  # after creating or destroying instances
vastutils bootstrap vast owner/repo             # once per new instance, per repo
ssh vast                                        # newest instance, localhost:8080 forwarded
```

`vastutils help` has the full reference.

## How it fits together

| Piece | Where | Changes |
|---|---|---|
| Shared SSH options (user `root`, key, forwards, known_hosts) | `Host vast vast-* *.vast.ai` in the home-manager SSH config | rarely, by rebuilding |
| Per-instance `HostName`/`Port` | `~/.ssh/config.d/vast.conf`, written by `vastutils sync` | every new instance, no rebuild |
| GitHub access on an instance | per-instance deploy key made by `vastutils bootstrap` | created per instance, deleted by `sync` |

`~/.ssh/config` ends with `Match all` + `Include config.d/*.conf`, so the
generated file is picked up automatically. ssh keeps the first value it sees
for each option. The static block never sets `HostName`/`Port` and the
generated file sets nothing else, so they don't conflict.

Generated aliases:

- `vast-<ID>` for every running instance (ID as shown by `vastai show instances`).
  This uses the instance's **direct** public IP and mapped SSH port when vast
  exposes one, which is one hop shorter and doesn't depend on vast's proxy.
- `vast-<ID>-proxy` for the same instance through vast's `sshN.vast.ai` proxy.
  Use it when the direct port is unreachable.
- `vast` for the most recently started one (direct when available)
- each instance's bare public IP, with the full set of key options, so an
  `ssh -p PORT root@IP` command pasted from the vast console also works

These work for anything that reads ssh config: `scp`, `rsync`, VS Code/Zed
remote, `git`.

## The SSH key

vast.ai authorizes `~/.ssh/for_vastai` (registered in the vast account under
SSH keys). That key is **not** in my agent, so a bare
`ssh -p PORT root@ssh1.vast.ai` offers the wrong keys and fails with
`Permission denied (publickey)`. Always go through an alias, or pass
`-i ~/.ssh/for_vastai -o IdentitiesOnly=yes`. Matching `*.vast.ai` means
copy-pasted `ssh1.vast.ai` commands also pick up the right key.

A bare public IP matches none of those patterns, so `vastutils sync` writes a
self-contained block for each running instance's IP. Pasted direct commands
work after a sync. Before a sync they fall back to your agent keys, and the
server asks for a password.

## GitHub access: per-instance deploy keys

Agent forwarding is deliberately **off** for vast hosts. While a forwarded
session is open, anyone with root on the host machine can use every key in my
agent, including the one that can push to all my GitHub repos.

Instead, `vastutils bootstrap <alias> owner/repo...`:

1. Generates `~/.ssh/gh_<owner>__<repo>` **on the instance**. The private key
   never leaves it.
2. Copies back the public half and adds it to the repo as a **write** deploy
   key titled `vast-<ID>` (via `gh`, using my laptop's `gh auth`).
3. Writes an instance-side `Host gh_<owner>__<repo>` ssh block, pins GitHub's
   host keys (fetched from the authenticated `gh api meta`, not trust-on-first-use
   on the instance's network), and adds git `insteadOf` rules so these URLs use
   the key:
   - `https://github.com/<owner>/<repo>.git`
   - `git@github.com:<owner>/<repo>.git`
4. Records `owner/repo<TAB>vast-<ID>` in
   `~/.local/state/vastutils/deploy-keys.tsv`.

It's idempotent, so re-running it on the same instance is harmless.

**Reaping:** `vastutils sync` (unless `--no-reap`) looks up each recorded key.
If its instance is no longer running, it deletes the deploy key from GitHub and
drops the record. If the vast API call fails (such as an expired 2FA session),
sync aborts before touching anything, so it can never mistake an API error for
"all instances are gone".

### Caveats

- One key per repo per instance. That limit is the point: a compromised host
  can only touch the repos I bootstrapped, and only until I destroy it and run
  `sync`.
- A write deploy key can push to any branch. Protect `main` with a branch
  ruleset if that matters for the repo.
- Rewrites match the URL exactly, including case. GitHub ignores case in
  repo names but git's `insteadOf` doesn't, so `bootstrap` looks up the
  canonical `owner/repo` with `gh repo view` and uses that. Clone with the
  URL GitHub shows.
- `insteadOf` is prefix-based, so only the `.git`-suffixed HTTPS URL is
  rewritten. Clone with `.git` or with the `git@github.com:` form.
  (Rewriting `https://github.com/o/r` would also capture `o/r-other`.)
- Deploy keys added via `gh` are tied to its OAuth token. Logging `gh` out
  or revoking it removes them all, which is fine as a big red button.
- `gh` needs admin rights on the repo to manage deploy keys.

## One-time setup (new machine)

1. Enable the module (`tilde.vast.enable = true;`) and switch.
2. Put `for_vastai` in `~/.ssh/` (or set `tilde.vast.identityFile`) and make
   sure its `.pub` is in the vast account: `vastai show ssh-keys`.
3. `vastai set api-key <KEY>` and `vastai tfa login ...`.
4. `gh auth login`.

## Troubleshooting

- **`Permission denied (publickey)`**: you didn't go through an alias. Check
  with `ssh -G vast | grep identityfile`.
- **`vastai show instances failed ... 2FA`**: run `vastai tfa login`. Sync
  changed nothing.
- **Alias missing or stale**: run `vastutils sync`. Instances that are still
  loading have no `ssh_host` yet and are skipped, so re-run once it's up.
- **`kex_exchange_identification: Connection closed by remote host`** on
  `vast-<ID>-proxy`: vast's proxy isn't routing to the instance (seen on a
  fresh instance whose direct port worked fine). Use `vast-<ID>`, which goes
  direct.
- **`root@IP's password:` prompt**: the IP isn't in `vast.conf` yet. Run
  `vastutils sync`.
- **Host key changed warning**: vast reuses proxy ports. Remove the line from
  `~/.ssh/known_hosts.vast` (only vast hosts live there).
- **`bind [127.0.0.1]:8080: Address already in use`**: another session already
  holds the forward. Harmless, and `vastutils` itself never forwards.

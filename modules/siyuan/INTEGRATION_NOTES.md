# Integration Notes — siyuan module

## Getting it running

1. **Set a real access auth code.** Open `.env` at the repo root and fill in:
   ```
   SIYUAN_ACCESS_AUTH_CODE=<a-strong-random-code>
   ```
   It ships blank, which is only safe for localhost-only access.

2. **Confirm the other `.env` values suit this host** (defaults are usually fine):
   ```
   SIYUAN_IMAGE=b3log/siyuan:latest
   SIYUAN_CONTAINER_NAME=siyuan
   SIYUAN_PORT=6806
   SIYUAN_WORKSPACE_PATH=/srv/samba/siyuan-workspace
   SAMBA_SHARE_NAME=siyuan-workspace
   SAMBA_VALID_GROUP=siyuan-users
   ```

3. **Confirm Samba is already installed** on this host — `configure.sh` expects
   `/etc/samba/smb.conf` to exist already (it's set up at the node level via
   `scripts/install/install_samba.sh`, not per-module). This is already true
   for the desktop/infrastructure node.

4. **Install the module** (resolves the `docker`/`filesystem` dependencies
   automatically, in order, before running `siyuan`'s own `install.sh`):
   ```bash
   sudo make install-siyuan
   ```

5. **Wire up the Samba share:**
   ```bash
   sudo make configure-siyuan
   ```

6. **Check it worked:**
   ```bash
   make verify-siyuan   # container running + web UI reachable
   make status-siyuan   # container status + samba share visibility
   ```

7. **Open it.** Locally: `http://localhost:6806/`. Over Tailscale (e.g. from
   the iPhone): `http://<tailscale-hostname-or-ip>:6806/`, entering the
   access auth code from step 1 when prompted. Optionally "Add to Home
   Screen" from Safari for an app-like icon — see the Mobile access section
   below for why this is the supported path instead of the native app.

8. **Add a Samba user** if you want to browse the workspace files directly
   for backup/inspection (not for live editing — see the single-writer note
   below):
   ```bash
   sudo usermod -aG siyuan-users <username>
   sudo smbpasswd -a <username>
   ```

To tear down later: `sudo make remove-siyuan` (stops/removes the container;
leaves workspace data and the Samba share entry in place on purpose).

## Verified against the real repo (previous drafts of this module guessed)

Earlier drafts of this module were built without access to the actual
framework and got several things wrong. Corrected against the real repo:

- **`module.yml` schema**: `name`, `description`, `version`, `category`,
  `capabilities` (list), `dependencies` (list of other module names). No
  `config` block, no `install.script`, no `templates` list, no `validate`
  block — those were invented and don't match any other module.
- **Script-per-action, not one big install.sh**: the framework dispatches
  `modules/<name>/<action>.sh` directly (`scripts/lib/modules.sh:
  module_script`). This module now has `install.sh`, `configure.sh`,
  `verify.sh`, `status.sh`, `remove.sh` — matching `docker`/`webmin`'s shape.
- **No per-module Makefile in the convention**: the root Makefile
  auto-generates `install-siyuan`, `configure-siyuan`, `verify-siyuan`,
  `status-siyuan`, `remove-siyuan` (etc.) for every module via
  `MODULE_ACTION_TEMPLATE` + `scripts/lib/modules.sh`. The `Makefile` kept
  in this module now delegates to that instead of reimplementing it, and
  only adds things the framework doesn't model (raw compose lifecycle,
  markdown export, backup).
- **Config lives in `.env`, not per-module defaults**: `scripts/lib/env.sh`
  provides `load_dotenv`, sourced by each script, with `${VAR:-default}`
  fallbacks inline. Added `SIYUAN_*` / `SAMBA_*` keys to `.env` and
  `.env.example` rather than a `module.yml` config block.
- **No `conf.d` Samba convention**: the framework's own
  `scripts/configure/configure_samba_shares.sh` appends share blocks
  directly to `/etc/samba/smb.conf` with a `grep -q "\[ShareName\]"` guard.
  `configure.sh` now follows that exact pattern instead of a rendered
  `conf.d` include (the old `samba-share.conf.tmpl` is deprecated,
  kept only for history).
- **There is no `samba` module.** Samba itself (packages + base shares) is
  installed at the node level (`desktop:` target in the root Makefile →
  `scripts/install/install_samba.sh` + `configure_samba_shares.sh`), not
  per-module. `configure.sh` assumes Samba is already installed and aborts
  with a clear message if `/etc/samba/smb.conf` doesn't exist yet.
- **No dry-run support anywhere in the framework.** Removed — none of the
  reference modules (`docker`, `webmin`, `network`, `nfs`) have it.
- **`dependencies` reference real module names**: `docker`, `filesystem`
  (both exist). Dependencies are resolved and run in order by
  `scripts/lib/modules.sh` before this module's own action runs — so
  `docker` will already be installed by the time `install.sh` executes.

## Design decisions specific to this module (still accurate)

**Single-writer model.** SiYuan isn't designed for concurrent multi-process
writes to its workspace. The Samba share exists for backup/inspection/manual
export access, not live co-editing while the container runs.

**Native storage format is not markdown.** SiYuan persists notes as `.sy`
JSON block files. The Samba share exposes the real, authoritative data —
just not in a format other markdown tools can read directly without an
export step (`make export-md` triggers SiYuan's own workspace → Markdown
export via its API).

## Mobile access (confirmed against real iOS app behavior)

The SiYuan iOS app does **not** support connecting to a remote kernel by
IP/auth-code. Its `Workspaces` screen only lists/opens local, on-device
workspaces; cross-device consistency is handled via the official S3/WebDAV
sync (a paid one-time unlock, ~$64) or the free community `Better Sync`
plugin — neither is deployed by this module.

**Chosen approach: browser/PWA access, no native app, no sync.** Any device
hits the Docker-hosted kernel directly in a browser at
`http://<tailscale-hostname-or-ip>:${SIYUAN_PORT}`, authenticates with
`SIYUAN_ACCESS_AUTH_CODE`, and can "Add to Home Screen" for an app-like
icon. This is a live thin client against the single server-hosted
workspace — no on-device copy to sync. Tradeoff: needs network
connectivity; no offline editing on mobile.

## Open items / not yet built

- No backup/versioning job wired into the framework's own module actions
  (SiYuan has built-in snapshot/history; nothing ships that off-box beyond
  the `make backup` convenience target, which isn't part of `module.yml`'s
  declared capabilities).
- No automated tests, consistent with the rest of the framework's current
  modules.
- Auth hardening beyond `SIYUAN_ACCESS_AUTH_CODE` (e.g. a reverse proxy with
  real auth) is left to the operator if this is ever exposed beyond
  Tailscale.
- Community SiYuan MCP servers (e.g. `zhizhiqq/siyuan-mcp`) were discussed
  as an optional way to let an AI agent operate on this workspace via
  Docker Desktop's MCP Toolkit, using `SIYUAN_ACCESS_AUTH_CODE` as the API
  token. Not deployed by this module — noted here as a possible future
  addition, with the caveat that these are third-party projects of varying
  maturity, not maintained by the SiYuan team.

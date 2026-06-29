# CHANGELOG

## 2026.06.29

### What Changed
- **New "Kiro Apps" application menu** grouping all the Kiro tweak/config tools in
  one launcher folder (alongside the existing "Kiro" menu). Added a second `<Menu>`
  block to `etc/skel/.config/menus/applications-merged/kiro.menu` that includes the
  new `X-Kiro-Apps` category and orders the entries: Arch Linux Tweak Tool, Kiro ISO
  Builder, Alacritty/Fastfetch/Fish Tweak Tools, ArchLinux Logout Settings,
  Betterlockscreen. Hyprland Tweak Tool is intentionally excluded — it is the
  Wayland/KIROTUX line, not part of the X11 Kiro ISO.

### Technical Details
- Same freedesktop pattern as the existing Kiro menu: category include + `<Layout>`
  for ordering + `<Merge type="all"/>`. The `kiro-apps.directory` it references is
  shipped by `kiro-system-files`. Each tool's `.desktop` gained `X-Kiro-Apps;`
  appended to its `Categories=` (non-destructive — they still appear under
  Settings/System too).

### Files Modified
- `etc/skel/.config/menus/applications-merged/kiro.menu`

## 2026.06.23

### What Changed
- **New default fastfetch look in `/etc/skel`** — replaced
  `etc/skel/.config/fastfetch/config.jsonc` with the current Kiro boxed layout
  (truecolor Kiro **K** logo, `>  ` separator with red separator colour, the
  ╔══╣══╚ box-drawing frame around kernel/uptime/distro/desktop/term/shell/
  cpu+temp/gpu/disk/memory/network + a colors row), matching the new bundled
  default in `fastfetch-tweak-tool`.
- **Fixed a shipped privacy leak + broken logo.** The old skel config pointed
  the logo at `/home/erik/KIRO/fastfetch-tweak-tool/...` — Erik's home path,
  which leaked his environment and **does not exist on any user's machine**, so
  the logo silently failed out of the box. The config is now **self-contained**:
  the Kiro **K** art ships beside it as
  `etc/skel/.config/fastfetch/kiro-color-24.txt` and the logo source is
  `~/.config/fastfetch/kiro-color-24.txt` (verified fastfetch expands `~`), so it
  works for every user with no dependency on `fastfetch-tweak-tool` being
  installed (it is not on the ISO — only `fastfetch-git` is).

### Files Modified
- `etc/skel/.config/fastfetch/config.jsonc` — new default layout, self-contained logo path.
- `etc/skel/.config/fastfetch/kiro-color-24.txt` — bundled Kiro K ASCII/truecolor art (new).

## 2026.06.14

### What Changed
- Added **Kiro Assistant** to the **Kiro** applications-menu folder. The
  `<Layout>` in `kiro.menu` now lists `kiro-assistant.desktop` explicitly
  (alongside the existing `<Merge type="all"/>` safety net), so it appears in
  the Kiro folder with the rest of the Kiro entries.

### Technical Details
- The app's `kiro-assistant.desktop` (shipped by the `kiro-assistant` package)
  gained the `X-Kiro` category, which is what `kiro.menu`'s
  `<Include><Category>X-Kiro</Category>` selects on. Listing the filename in the
  Layout keeps inclusion explicit and avoids the historic suppression gotcha.
- Reaches existing users via `kiro-skell` (the user-side `applications-merged/`
  fragment is not package-delivered).

### Files Modified
- `etc/skel/.config/menus/applications-merged/kiro.menu`

## 2026.06.13

### What Changed
- Fixed the **Kiro** submenu hiding new entries: `kiro.menu`'s `<Layout>` listed the
  four web-link launchers explicitly with no `<Merge type="all"/>`, so garcon showed
  *only* those four and hid any other `X-Kiro` app — which is why the new
  `kiro-news.desktop` (from the `kiro-news` package, arriving as a `kiro-system-files`
  dependency) never appeared in the menu on fresh installs. Added `kiro-news.desktop`
  to the Layout and a `<Merge type="all"/>` safety net so future `X-Kiro` apps can't be
  silently hidden again.

- **Real root cause (confirmed empirically on a VirtualBox VM, not by tooling):**
  Whisker/garcon renders the Kiro folder **only from the user's
  `~/.config/menus/applications-merged/kiro.menu`** — *not* from any system menu
  dir, and *not* from `xfce-applications-merged/`. (GMenu/`gnome-menus` reads
  `xfce-applications-merged/` and reported success, which sent an earlier attempt
  down a wrong path — GMenu is **not** the resolver Whisker uses.) kiro-news was
  hidden purely because that user file's old `<Layout>` listed only the 4 links
  with no `<Merge type="all"/>`, suppressing the unlisted entry.
- **Fix:** keep the menu fragment in **`/etc/skel/.config/menus/applications-merged/kiro.menu`**
  (its original location) with the corrected Layout — kiro-news + the 4 links +
  `<Merge type="all"/>`. The launchers and `kiro.directory` stay system-wide in
  `/usr/share` (those *do* reach every user via the package — proven by
  `kiro-news.desktop` rendering from `/usr/share/applications`). The menu fragment
  is the one piece that must be per-user.
- **Delivery:** new accounts get it from skel automatically. **Existing users keep
  their stale `~/.config/menus/applications-merged/kiro.menu`** (old Layout) — they
  need **`kiro-skell`** to refresh it. (Honest constraint: the menu fragment is not
  purely package-delivered for existing users.)

### Technical Details
- `etc/skel/.config/menus/applications-merged/kiro.menu` — corrected Layout
  (kiro-news first, 4 links, `<Merge type="all"/>`). Reverts the mistaken
  `/etc/xdg/menus/xfce-applications-merged/` placement from earlier today.
- `usr/share/applications/kiro-link-*.desktop` + `usr/share/desktop-directories/kiro.directory`
  remain system-wide (kept). `kiro-news.desktop` ships from the `kiro-news` package.

## 2026.06.09

### What Changed
- Added a **Kiro** submenu to the XFCE applications menu with four web-link launchers
  (each opens a site via `xdg-open`), so users can reach the project's key destinations
  straight from the menu — no welcome app. Links: Kiro Website (https://kiroproject.be),
  Kiro Releases (https://kiroproject.be/releases.html), Kiro Discussions
  (https://github.com/kirodubes/kiro-discussions/discussions), Kiro Source Code
  (https://github.com/kirodubes). Each launcher uses a distinct coloured Kiro icon
  (`kiro`, `kiro-green`, `kiro-bleu`, `kiro-white`). Verified live on the kiro VM.

### Technical Details
- Implemented as a standard XDG menu drop-in (NOT a frozen full menu): a `.directory`
  defines the submenu, an `applications-merged` drop-in merges it into the stock menu via
  its `DefaultMergeDirs`/`Merge type="all"`, and the launchers carry a clean `X-Kiro`
  category. This survives future app additions, unlike MenuLibre's full `xfce-applications.menu`
  rewrite (which overrides the stock menu and *hides* the submenu — do not ship it; if it
  reappears in a user's `~/.config/menus/`, delete it).
- Whisker menu sorts category items alphabetically and ignores the menu `<Layout>`, so the
  displayed order is alphabetical (Discussions, Releases, Source Code, Website). A `<Layout>`
  is kept for non-Whisker menus; a custom order would require globally disabling Whisker's
  alphabetical sort, which we chose not to impose.
- The `kiro-white` icon ships from **kiro-system-files**
  (`usr/share/icons/hicolor/scalable/apps/kiro-white.png`); the other three colours were
  already present there.

### Files Modified
- etc/skel/.local/share/desktop-directories/kiro.directory (new)
- etc/skel/.config/menus/applications-merged/kiro.menu (new)
- etc/skel/.local/share/applications/kiro-link-{website,releases,discussions,code}.desktop (new)
- CHANGELOG.md

## 2026.05.24

### What Changed
- Removed `etc/skel/.config/gtk-3.0/bookmarks` because it hardcoded `/home/erik/...` paths that break for every other user. GTK already shows the standard XDG folders (Home, Desktop, Documents, Downloads, Music, Pictures, Videos) plus Trash in the file-manager sidebar automatically via `~/.config/user-dirs.dirs`, so users still get the default folders without it.

### Technical Details
- The GTK bookmarks format requires literal absolute `file://` paths and does not expand `$HOME`/`~`, so per-user correctness would have needed a first-login rewrite script. Removing the file was simpler than maintaining that and only dropped the custom (non-XDG) entries — Projects, DATA, .config, .icons, .themes.
- Note: [.fehbg](etc/skel/.fehbg) and [variety.desktop](etc/skel/.config/autostart/variety.desktop) still contain hardcoded `/home/erik` paths (left untouched this session).

### Files Modified
- CHANGELOG.md
- etc/skel/.config/gtk-3.0/bookmarks (removed)

## 2026.05.21

### What Changed
- Added the four other required markdown scaffold files (created stubs for whichever of `IDEAS.md` / `TODO.md` / `CLAUDE.md` were missing) per the new ecosystem MD-scaffold rule codified in [Kiro-HQ/CLAUDE.md](/home/erik/Insync/Kiro/Kiro-HQ/CLAUDE.md#required-markdown-scaffold-every-repo). README was already substantial; left untouched.

### Files Modified
- CHANGELOG.md
- IDEAS.md (created where missing)
- TODO.md (created where missing)
- CLAUDE.md (created where missing)

## 2026.05.01

**What Changed:** Added CLAUDE.md and CHANGELOG.md to document the repo for Claude Code sessions.

**Technical Details:** CLAUDE.md covers deployment workflow, directory layout, validation commands, shell script conventions, and non-obvious config values (intentional `vm.swappiness=100`, disabled laptop udev rule, pacman GPG key prerequisite).

**Files Modified:** `CLAUDE.md` (created), `CHANGELOG.md` (created)

---

## 2026.04.15 – 2026.04.30

**What Changed:** Major migration from ArcoLinux/edu branding to Kiro. Added Kiro-specific system optimization configs and a comprehensive validation script. Removed large volume of legacy components no longer applicable to the Kiro desktop target.

**Technical Details:**

- Systemd optimization suite added: `journald.conf.d/`, `system.conf.d/`, `user.conf.d/`, `coredump.conf.d/`, `systemd-logind.service.d/` — all centralized under `etc/systemd/`
- `etc/skel/.bin/edu-check-optimizations` added (607 lines) — validates ZRAM, BBR, THP, GPU, kernel params live on the running system
- `usr/local/share/edu/` renamed to `usr/local/share/kiro/` (pacman.conf, gpg.conf, nsswitch.conf, mirrorlist)
- `etc/sysctl.d/99-kiro-optimizations.conf` and full `etc/udev/rules.d/` rule set added for kernel/device tuning
- `README.md` written documenting all kernel params, udev rules, and systemd settings with validation status
- Alacritty theme renamed from `default-arcolinux.toml` to `default-kiro.toml`

**Removed (legacy cleanup):**

- `etc/modprobe.d/` — all entries (amdgpu, audio-hda, nvidia, realtek, intel-ethernet, nobeep, blacklist-watchdog, etc.)
- `etc/X11/xorg.conf.d/` — touchpad and killX rules
- `etc/samba/` — smb.conf examples
- `etc/pacman.d/hooks/` — bootloader hook
- `etc/skel/.bin/` — powermenu-change-colors, powermenu-change-style, starwars
- `etc/skel/.config/nlogout/` — entire nlogout application (source, themes, binary)
- `etc/skel/.config/nitrogen/` and `etc/skel/.config/powermenu/`
- `usr/local/bin/` — ~20 system scripts (sfetch, skel, use, var, velo, sysinfo, toggle-chaotic-repo, remove-socials, and others)
- `usr/share/backgrounds/arco/` — ArcoLinux wallpapers

**Files Modified:** `etc/systemd/**`, `etc/sysctl.d/99-kiro-optimizations.conf`, `etc/udev/rules.d/**`, `etc/skel/.bin/edu-check-optimizations`, `usr/local/share/kiro/**`, `README.md`, `LICENSE`, `.gitignore`

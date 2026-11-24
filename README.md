# Steam Theme Sync

An Omarchy plugin that recolors the Steam client with your active Omarchy
theme, and updates open Steam windows within a couple of seconds when you
switch themes. No Steam restart is needed after the first setup.

## How it works

Steam's interface hard-codes most of its colors instead of using CSS
variables, so a fixed theme cannot follow your palette. This plugin reads
Steam's own stylesheets on your machine, finds every rule that uses Steam's
neutral backgrounds, grey text or its blue accent, and writes the same rules
with colors from your Omarchy theme
(`~/.local/state/omarchy/current/theme/colors.toml`):

- Steam's dark backgrounds map to your theme's background shades.
- Grey text maps to your theme's foreground shades.
- Steam's blue accent maps to your theme's accent.
- Saturated colors (achievements, red and green badges), pure white and pure
  black stay as they are.

The result is a [Millennium](https://steambrew.app) theme named **Omarchy**
in `~/.local/share/Steam/millennium/themes/omarchy/`. The plugin's service
regenerates it on shell start and whenever Omarchy applies a new theme. A
small script inside the theme notices the new files and reloads the CSS in
every open Steam window.

The generated theme is built from your local Steam install. Nothing from
Steam is shipped in this repository.

## Requirements

- Omarchy with the Quickshell-based shell
- The native Steam package (`steam` from pacman). The Flatpak build is not
  supported.
- [Millennium](https://github.com/SteamClientHomebrew/Millennium), installed
  from the AUR. Use the `millennium` package: `millennium-bin` lacks the
  64-bit bootstrap that the current Steam client (`steamrt64`) loads.
- Python 3.11 or newer (preinstalled on Omarchy)

Millennium is a third-party Steam client mod. It is not affiliated with
Valve, and a Steam update can break it until Millennium catches up.

## Install

1. Install Millennium, then start Steam once so it creates its folders:

   ```bash
   yay -S millennium
   ```

2. Add the plugin:

   ```bash
   omarchy plugin add https://github.com/Lik1ch/omarchy-steam-theme-sync --enable
   ```

3. In Steam, open Millennium's settings, go to **Themes** and select
   **Omarchy**. Restart Steam once.

From then on, switching your Omarchy theme recolors Steam live.

To regenerate by hand, for example after a large Steam update changed its
stylesheets:

```bash
python3 ~/.config/omarchy/plugins/io.github.lik1ch.steam-theme-sync/bin/steam-theme-sync
```

## Remove

1. In Steam's Millennium settings, switch the theme back to **Default**.
2. Remove the plugin and the generated theme:

   ```bash
   python3 ~/.config/omarchy/plugins/io.github.lik1ch.steam-theme-sync/bin/steam-theme-sync --remove
   omarchy plugin remove io.github.lik1ch.steam-theme-sync
   ```

3. Optionally remove Millennium itself with `yay -R millennium`.

## Limitations

- Colors that Steam sets inline from JavaScript, and game artwork, are not
  recolored.
- Steam updates can rename or restyle elements. Switching your Omarchy theme
  or running the generator again picks up the new stylesheets.

## License

MIT, see [LICENSE](LICENSE).

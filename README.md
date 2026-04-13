# dotfiles

Personal Arch Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each directory is a Stow package — it mirrors the structure of `$HOME`.

```
dotfiles/
  zsh/        → ~/.zshrc
  nvim/       → ~/.config/nvim/
  hypr/       → ~/.config/hypr/
  waybar/     → ~/.config/waybar/
  ...
```

## Install

```bash
git clone https://github.com/XVll/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
./stow.sh
```

## Packages

| Package | Description |
|---|---|
| `zsh` | Shell + aliases |
| `nvim` | Neovim (LazyVim) |
| `hypr` | Hyprland WM |
| `waybar` | Status bar |
| `wofi` | App launcher |
| `wezterm` | Terminal emulator |

## Theme
* GitDiff
* LazyGit
* Hyprland
* Terminal
* Waybar
* LazyVim
* Walker
* Ghostty
* Icons
* Wallpaper

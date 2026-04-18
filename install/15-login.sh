#!/bin/bash

# Login domain: greetd + Dank greeter, uwsm session manager, secret store

pkg-add greetd-dms-greeter-git uwsm gnome-keyring

cd "$DOTFILES" && stow -d stow -t "$HOME" login

# Enables greetd.service and configures PAM + dms-greeter; sync copies
# theme/wallpaper/ACLs so the greeter can read your DMS state.
dms greeter enable
dms greeter sync

#!/bin/bash

# Login domain: greetd + Dank greeter, session secret store

pkg-add greetd-dms-greeter-git gnome-keyring

# Enables greetd.service and configures PAM + dms-greeter; sync copies
# theme/wallpaper/ACLs so the greeter can read your DMS state.
dms greeter enable
dms greeter sync

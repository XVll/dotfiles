#!/bin/bash

# Login domain: greetd + Dank greeter (matches DMS theme)

pkg-add greetd-dms-greeter-git

# Enables greetd.service and configures PAM + dms-greeter; sync copies
# theme/wallpaper/ACLs so the greeter can read your DMS state.
dms greeter enable
dms greeter sync

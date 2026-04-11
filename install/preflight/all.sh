#!/usr/bin/env bash
# Preflight — run pacman.sh/user.sh/base.sh as root, then paru.sh as fx
DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$DIR/pacman.sh"
source "$DIR/user.sh"
source "$DIR/base.sh"
source "$DIR/paru.sh"

#!/bin/bash

out() { printf "$1 $2\n" "${@:3}"; }
error() { out "==> ERROR:" "$@"; } >&2
die() { error "$@"; exit 1; }

(( $# )) || die "No root directory specified"
newroot=$1; shift
pacman_args=("${@:-base}")

if [[ $EUID -ne 0 ]]; then
	die "This script must be run as root"
fi

[[ -d $newroot ]] || die "%s is not a directory" "$newroot"

echo 'Creating install root at %s' "$newroot"
mkdir -m 0755 -p "$newroot"/var/{cache/pacman/pkg,lib/pacman,log} "$newroot"/{dev,run,etc}
mkdir -m 1777 -p "$newroot"/tmp
mkdir -m 0555 -p "$newroot"/{sys,proc}

echo 'Creating /dev/null in new root'
mknod "$newroot/dev/null" c 1 3

echo 'Installing packages to %s' "$newroot"
if ! pacman -r "$newroot" -Sy --noconfirm "${pacman_args[@]}"; then
	die 'Failed to install packages to new root'
fi

echo 'Deleting /dev/null from new root'
rm "$newroot/dev/null"
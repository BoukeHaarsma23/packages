#! /bin/bash

set -e
set -x
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

location=pkgs-stage-2
rm -rf $location/$2-chimeraos
mkdir $location/$2-chimeraos
cp -rv $1/$2/* $location/$2-chimeraos
# Suffix package with -chimeraos
sed -i '/^pkgbase=/s/$/-chimeraos/' $location/$2-chimeraos/PKGBUILD
# In the prepare function replace
# echo "$pkgver-arch$epoch.$pkgrel" >VERSION
sed -i '/.*echo \"\$pkgver.*/s/arch/chos/' $location/$2-chimeraos/PKGBUILD

# Add patches to sources
# https://stackoverflow.com/a/52057667
for patch in $SCRIPT_DIR/*.patch
do
    patchname=${patch##*/}
    sed -i '/^source.*/{:a;/)/!{N;ba};s/)/'${patchname}'\n)\n/;}' $location/$2-chimeraos/PKGBUILD
done
pushd "$location/$2-chimeraos"
# plumb patches in folder
cp -v $SCRIPT_DIR/*.patch .
# remove git folder
rm -rf .git/
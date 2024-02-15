#! /bin/bash

set -e
set -x
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cp -rv $1/$2 $3/$2-chimeraos
# Suffix package with -chimeraos
sed -i '/^pkgbase=/s/$/-chimeraos/' $3/$2-chimeraos/PKGBUILD
# In the prepare function replace
# echo "$pkgver-arch$epoch.$pkgrel" >VERSION
sed -i '/.*echo \"\$pkgver.*/s/arch/chos/' $3/$2-chimeraos/PKGBUILD

# Add patches to sources
# https://stackoverflow.com/a/52057667
#sed '/^source.*/{:a;/)/!{N;ba};s/)/bla)/;}' PKGBUILD
#sed -i '/^source.*/{:a;/)/!{N;ba};s/)/bla)/;}' PKGBUILD
for patch in $SCRIPT_DIR/*.patch
do
    patchname=${patch##*/}
    sed -i '/^source.*/{:a;/)/!{N;ba};s/)/'${patchname}'\n)\n/;}' $3/$2-chimeraos/PKGBUILD
done
pushd "$3/$2-chimeraos"
# plumb patches in folder and update checksums
cp -v $SCRIPT_DIR/*.patch .
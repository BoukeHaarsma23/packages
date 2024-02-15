pushd $2
	git submodule add "https://aur.archlinux.org/$1.git"
popd

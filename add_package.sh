pushd pkgs
	git submodule add "https://gitlab.archlinux.org/archlinux/packaging/packages/$1.git"
popd

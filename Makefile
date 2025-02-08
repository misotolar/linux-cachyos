.PHONY: *

PWD:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

all: clean update srcinfo world

clean:
	rm -rf $(PWD){makepkg,01*.patch,config,auto-cpu-optimization.sh}

update:
	updpkgsums

srcinfo:
	makepkg --printsrcinfo > .SRCINFO

world:
	BUILDDIR="$(PWD)makepkg" KBUILD_BUILD_USER="$(shell whoami)" KBUILD_BUILD_HOST="$(shell hostname)" makepkg -cfisr

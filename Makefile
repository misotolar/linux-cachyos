.PHONY: *

PWD := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

AUTOFDO_PROFILE :=
ifeq ($(shell test -e $(PWD)autofdo/$(shell hostname).afdo && echo -n yes),yes)
	AUTOFDO_PROFILE := $(PWD)autofdo/$(shell hostname).afdo
endif

PROPELLER_PREFIX :=
ifeq ($(shell test -e $(PWD)autofdo/propeller/$(shell hostname)_cc_profile.txt && echo -n yes),yes)
ifeq ($(shell test -e $(PWD)autofdo/propeller/$(shell hostname)_ld_profile.txt && echo -n yes),yes)
	PROPELLER_PREFIX := $(PWD)autofdo/propeller/$(shell hostname)
endif
endif

all: clean update srcinfo world

clean:
	rm -rf $(PWD){src,config,01*.patch,01*.revert}

update:
	updpkgsums

srcinfo:
	makepkg --printsrcinfo > .SRCINFO

world:
	KBUILD_BUILD_USER="$(shell whoami)" \
	KBUILD_BUILD_HOST="$(shell hostname)" \
	KBUILD_AUTOFDO_PROFILE="$(AUTOFDO_PROFILE)" \
	KBUILD_PROPELLER_PROFILE_PREFIX="$(PROPELLER_PREFIX)" \
	makepkg -cfisr

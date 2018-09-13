MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
project_dir := $(dir $(mkfile_path))

# Local pip is used by creating virtualenv and running `source ./bin/activate`

#    all: the name of the default target
#    check: runs tests, linters, and style enforcers
#    clean: removes files created by all
#    install:
#    uninstall: undoes what install did

# Workflow should be:
# sudo ./init.sh; # Sets up a new ubuntu server with base stuff and dev user
# sudo ./bin/setup.sh # should only need to be run once
# virtualenv .;
# source ./bin/activate;
# make ENVIRONMENT=development;
# sudo make ENVIRONMENT=development install;
#
# sudo make ENVIRONMENT=development uninstall;
# make ENVIRONMENT=development clean;
#

#Use order only prerequisites for making directories

# Set to tmp/ when debugging the install
# make PREFIXDIR=${PWD}/tmp inspect.SRVDIR
# make PREFIXDIR=${PWD}/tmp ENVIRONMENT=development install
PREFIXDIR :=
# Set to development or production
ENVIRONMENT := development
PORTREGISTRY := ${PWD}/port-registry.cfg
SRVDIR := $(PREFIXDIR)/srv/timeline/
NGINXDIR := $(PREFIXDIR)/etc/nginx/
SYSTEMDDIR := $(PREFIXDIR)/etc/systemd/system/
DATABASEDIR := $(PREFIXDIR)/var/lib/timeline/sqlite3/
NGINXLOGDIR := $(PREFIXDIR)/var/log/nginx/timeline/
AWSTATSLOGDIR := $(PREFIXDIR)/var/log/awstats/timeline/

# Get the version from the package.json
TAG := $(shell cat package.json | python -c 'import sys, json; print json.load(sys.stdin)["version"]')

# For debugging what is set in variables
inspect.%:
	@echo $($*)

ifeq ($(shell which virtualenv),)
$(error run "./bin/setup.sh" to install virtualenv)
endif
ifeq ($(shell ls bin/activate),)
$(error run "virtualenv .")
endif
ifneq ($(shell which pip),$(project_dir)bin/pip)
$(warning run "source bin/activate" to activate the virtualenv. Using $(shell which pip). Ignore this warning if using sudo make install.)
endif

# Always run.  Useful when target is like targetname.% .
# Use $* to get the stem
FORCE:

objects := site.cfg web/timeline.conf


#####

web/dhparam.pem:
	openssl dhparam -out $@ 2048

bin/chill: chill/requirements.txt requirements.txt
	pip install -r $<
	touch $@;

objects += chill/timeline-chill.service
chill/timeline-chill.service: chill/timeline-chill.service.sh
	./$< $(project_dir) > $@

# Create a tar of the frozen directory to prevent manually updating files within it.
# For this app the front end resources are all created via `npm run build` and
# only need to be 'frozen' when creating a dist for production.
#objects += frozen.tar.gz
frozen.tar.gz: package.json $(shell find src/ -type f -print)
	bin/freeze.sh $@

site.cfg: site.cfg.sh $(PORTREGISTRY)
	./$< $(ENVIRONMENT) $(DATABASEDIR) $(PORTREGISTRY) > $@

web/timeline.conf: web/timeline.conf.sh $(PORTREGISTRY)
	./$< $(ENVIRONMENT) $(SRVDIR) $(NGINXLOGDIR) $(PORTREGISTRY) > $@

.PHONY: $(TAG).tar.gz
$(TAG).tar.gz: bin/dist.sh frozen.tar.gz
	./$< $@

######

.PHONY: all
all: bin/chill $(objects)

.PHONY: install
install:
	./bin/install.sh $(SRVDIR) $(NGINXDIR) $(NGINXLOGDIR) $(AWSTATSLOGDIR) $(SYSTEMDDIR) $(DATABASEDIR)

# Remove any created files in the src directory which were created by the
# `make all` recipe.
.PHONY: clean
clean:
	rm $(objects)
	pip uninstall --yes -r chill/requirements.txt

# Remove files placed outside of src directory and uninstall app.
# Will also remove the sqlite database file.
.PHONY: uninstall
uninstall:
	./bin/uninstall.sh $(SRVDIR) $(NGINXDIR) $(SYSTEMDDIR) $(DATABASEDIR)

.PHONY: dist
dist: $(TAG).tar.gz


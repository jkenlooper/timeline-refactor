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

objects := site.cfg web/timeline.conf stats/awstats.timeline.weboftomorrow.com.conf stats/awstats-timeline-crontab


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
objects += frozen.tar.gz
frozen.tar.gz: db.dump.sql site.cfg package.json $(shell find templates/ -type f -print) $(shell find documents/ -type f -print) $(shell find queries/ -type f -print)
	bin/freeze.sh $@

bin/timeline-api: api/requirements.txt requirements.txt
	pip install -r $<
	touch $@;


objects += api/timeline-api.service
api/timeline-api.service: api/timeline-api.service.sh
	./$< $(project_dir) > $@

site.cfg: site.cfg.sh $(PORTREGISTRY)
	./$< $(ENVIRONMENT) $(DATABASEDIR) $(PORTREGISTRY) > $@

web/timeline.conf: web/timeline.conf.sh $(PORTREGISTRY)
	./$< $(ENVIRONMENT) $(SRVDIR) $(NGINXLOGDIR) $(PORTREGISTRY) > $@

ifeq ($(ENVIRONMENT),production)
# Only create the dhparam.pem if needed.
objects += web/dhparam.pem
web/timeline.conf: web/dhparam.pem
endif

stats/awstats.timeline.weboftomorrow.com.conf: stats/awstats.timeline.weboftomorrow.com.conf.sh
	./$< $(NGINXLOGDIR) > $@

stats/awstats-timeline-crontab: stats/awstats-timeline-crontab.sh
	./$< $(SRVDIR) $(AWSTATSLOGDIR) > $@

.PHONY: $(TAG).tar.gz
$(TAG).tar.gz: bin/dist.sh
	./$< $@

######

.PHONY: all
all: bin/chill bin/timeline-api $(objects)

.PHONY: install
install:
	./bin/install.sh $(SRVDIR) $(NGINXDIR) $(NGINXLOGDIR) $(AWSTATSLOGDIR) $(SYSTEMDDIR) $(DATABASEDIR)

# Remove any created files in the src directory which were created by the
# `make all` recipe.
.PHONY: clean
clean:
	rm $(objects)
	pip uninstall --yes -r chill/requirements.txt
	pip uninstall --yes -r api/requirements.txt

# Remove files placed outside of src directory and uninstall app.
# Will also remove the sqlite database file.
.PHONY: uninstall
uninstall:
	./bin/uninstall.sh $(SRVDIR) $(NGINXDIR) $(SYSTEMDDIR) $(DATABASEDIR)

.PHONY: dist
dist: $(TAG).tar.gz

# all
# 	create (optimize, resize) media files from source-media
# 	install python apps using virtualenv and pip
# 	curl the awstats source or just include it?
#
# development
# 	create local server certs
# 	recreate dist files (npm run build). dist files will be rsynced back to
# 		local machine so they can be added in git.
# 	update any configs to be used for the development environment
#
# production
# 	run certbot certonly script (provision-certbot.sh)
# 	install crontab for certbot
# 	update nginx production config to uncomment certs?
#
# install
# 	create sqlite database file from db.dump.sql
# 		Only if db file is not there or has older timestamp?
# 	requires running as sudo
# 	install awstats and awstats.service
# 	install watcher service for changes to nginx confs that will reload
# 	create all directories
# 	rsync to all directories
# 	reload services if needed
#

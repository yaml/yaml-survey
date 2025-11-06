M := .cache/makes
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)
include $M/init.mk
include $M/python.mk
include $M/ys.mk
include $M/clean.mk
include $M/shell.mk

MAKES-CLEAN := config.yaml
MAKES-REALCLEAN += \
  credentials.json \
  token.pickle \

INPUT ?= \
  survey/engineers.yaml \

XXX := \
  survey/devops-managers.yaml \
  survey/executives.yaml \

TEST-INPUT ?= test-extended-types.yaml

INDEX := index.html
CONFIG := config.yaml
REQUIREMENTS := requirements.txt
PUBLISH := bin/publish-survey
INDEXER := bin/make-index
PYTHON-DEPS-INSTALLED := $(PYTHON-VENV)/bin/normalizer
PYTHON-DEPS := \
  $(PYTHON) \
  $(PYTHON-DEPS-INSTALLED) \

ifndef VERBOSE
QUIET := &>/dev/null
endif

test: $(TEST-INPUT)
	$(MAKE) clean publish INPUT=$< TEST-RUN=1

publish: $(INDEX)

config.yaml: always $(PYTHON-DEPS)
	$(PUBLISH) $(INPUT) $(QUIET)
	@echo
	@echo 'Link these forms to their respective sheets:'
	@grep '\-edit-url:' config.yaml
	@echo
	@echo 'Test these forms:'
	@grep '\-form-url:' config.yaml
	@echo

$(INDEX): index-template.html $(CONFIG) $(YS)
ifndef TEST-RUN
	$(INDEXER) $< $(CONFIG) > $@
endif

always:
	@:

$(PYTHON-DEPS-INSTALLED): $(REQUIREMENTS) $(PYTHON-VENV)
	pip install -r $<
	[[ -f $@ ]]

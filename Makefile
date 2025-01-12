TEMPFILE := $(shell mktemp -u)
GOPATH ?= go env GOPATH

all: install


$(GOPATH):
	mkdir -p $(GOPATH)/src

.PHONY: install
install:
	pip3 install -r requirements.txt
	python3 setup.py install

.PHONY: uninstall
uninstall:
	python3 setup.py install --record ${TEMPFILE} && \
		cat ${TEMPFILE} | xargs rm -rf && \
		rm -f ${TEMPFILE}

coala-venv:
	@echo ">>> Preparing virtual environment for coala"
	@# We need to run coala in a virtual env due to dependency issues
	virtualenv -p python3 venv-coala
	. venv-coala/bin/activate && pip3 install -r coala_requirements.txt

.PHONY: clean
clean:
	find . -name '*.pyc' -or -name '__pycache__' -or -name '*.py.orig' | xargs rm -rf
	rm -rf venv venv-coala coverage.xml
	rm -rf dist *.egg-info build docs/

.PHONY: devenv
devenv:
	pipenv install --dev

.PHONY: pytest
pytest:
	@echo ">>> Executing testsuite"
	python3 -m pytest -s --cov=./thoth/package_extract -vvl --timeout=2 test/

.PHONY: pylint
pylint:
	@echo ">>> Running pylint"
	pylint thoth/package_extract

.PHONY: coala
coala: coala-venv
	@echo ">>> Running coala"
	. venv-coala/bin/activate && coala --non-interactive

.PHONY: pydocstyle
pydocstyle:
	@echo ">>> Running pydocstyle"
	pydocstyle thoth/package_extract

.PHONY: check
check: pytest pylint pydocstyle coala


# Friendly aliases.
.PHONY: test
test: check

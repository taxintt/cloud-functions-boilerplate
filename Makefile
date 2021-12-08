PYTHON_VERSION:=3.9.0
UID := $(shell id -u)

ENTRYPOINT := hello

.PHONY: help
help: ## Display this help screen
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## setup for development
	for pkg in pyenv direnv; do \
		if [ `brew list $$pkg | wc -l | tr -d ' '` == 0 ]; then \
			brew install $$pkg || true; \
		fi \
	done

	if [ `pyenv versions | grep -c '$(PYTHON_VERSION)'` = "0" ]; then \
		pyenv install $(PYTHON_VERSION); \
	fi

	pyenv local $(PYTHON_VERSION)
	pyenv exec python -m venv .venv
	pyenv exec python -m pip install --upgrade pip
	.venv/bin/python -m pip install -r ./requirements.txt

	if [ ! -e $(HOME)/.envrc ]; then \
		touch $(HOME)/.direnvrc; \
	fi

	if [ `grep "direnv hook zsh" ~/.zshrc | wc -l | tr -d ' '` = "0" ]; then \
		echo 'eval "$(direnv hook zsh)"'; >> ~/.zshrc \
		source ~/.zshrc; \
	fi
	direnv allow


#
# stage local Tasks
#
.PHONY: local
local: ## ローカル開発環境を起動します
	functions-framework --target $(ENTRYPOINT) --debug

.PHONY: test
test: ## ローカル開発用にserverを起動します
	python ./djangosnippets/manage.py test


#
# stage dev Tasks
#
.PHONY: deploy-dev
deploy-dev: ## dev環境用にdeployを行います
	
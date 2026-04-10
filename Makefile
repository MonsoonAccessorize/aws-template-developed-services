.PHONY: install-hooks fmt lint validate docs security all

install-hooks:
	pip install pre-commit
	pre-commit install

fmt:
	pre-commit run terraform_fmt --all-files
	pre-commit run terragrunt_fmt --all-files

lint:
	pre-commit run terraform_tflint --all-files

validate:
	pre-commit run terraform_validate --all-files

docs:
	pre-commit run terraform_docs --all-files

security:
	pre-commit run terraform_trivy --all-files

all: fmt lint validate security

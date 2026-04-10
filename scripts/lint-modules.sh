#!/usr/bin/env bash
set -euo pipefail
pre-commit run terraform_tflint --all-files

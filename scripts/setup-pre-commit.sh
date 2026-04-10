#!/usr/bin/env bash
set -euo pipefail

echo "Installing pre-commit..."
pip install pre-commit

echo "Installing hooks..."
pre-commit install

echo "Done. Run 'pre-commit run --all-files' to validate."

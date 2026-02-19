#!/usr/bin/env bash
set -euo pipefail

echo "[quality-gate] scanning repository"

if rg -n '^(<<<<<<<|=======|>>>>>>>)' -- .; then
  echo "[quality-gate] merge conflict markers detected"
  exit 1
fi

if rg -n '(AKIA[0-9A-Z]{16}|-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----)' -- .; then
  echo "[quality-gate] potential secret pattern detected"
  exit 1
fi

echo "[quality-gate] passed"

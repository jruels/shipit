#!/usr/bin/env bash
# Lab 0 prerequisite checker. Confirms the local toolchain for the
# DevOps: CI/CD course is installed and current. Safe to run repeatedly.
set -uo pipefail

pass=0; fail=0
ok()   { printf "  \033[32mOK\033[0m   %s (%s)\n" "$1" "$2"; pass=$((pass+1)); }
bad()  { printf "  \033[31mFAIL\033[0m %s - %s\n" "$1" "$2"; fail=$((fail+1)); }

ver() { # ver <name> <command> <regex-to-extract> <min-major> <min-minor>
  local name="$1" cmd="$2" rx="$3" reqM="$4" reqm="$5"
  if ! command -v "${cmd%% *}" >/dev/null 2>&1; then bad "$name" "not installed"; return; fi
  local raw; raw="$(eval "$cmd" 2>/dev/null | grep -Eo "$rx" | head -1)"
  if [ -z "$raw" ]; then bad "$name" "installed but version not detected"; return; fi
  local M m; M="${raw%%.*}"; m="$(echo "$raw" | cut -d. -f2)"
  if [ "$M" -gt "$reqM" ] || { [ "$M" -eq "$reqM" ] && [ "${m:-0}" -ge "$reqm" ]; }; then
    ok "$name" "$raw"
  else
    bad "$name" "found $raw, need >= ${reqM}.${reqm}"
  fi
}

echo "Checking local tooling for DevOps: CI/CD..."
ver "Git"        "git --version"                 '[0-9]+\.[0-9]+(\.[0-9]+)?' 2 40
ver ".NET SDK"   "dotnet --version"              '[0-9]+\.[0-9]+(\.[0-9]+)?' 10 0
ver "kubectl"    "kubectl version --client -o yaml" '[0-9]+\.[0-9]+\.[0-9]+' 1 30
ver "Helm"       "helm version --short"          '[0-9]+\.[0-9]+\.[0-9]+'    3 14
ver "Azure CLI"  "az version -o tsv --query '\"azure-cli\"'" '[0-9]+\.[0-9]+\.[0-9]+' 2 60

# Docker: check the daemon is actually running, not just installed
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then ok "Docker" "daemon running"; else bad "Docker" "installed but daemon not running (start Docker Desktop)"; fi
else
  bad "Docker" "not installed"
fi

echo
if [ "$fail" -eq 0 ]; then
  printf "\033[32mAll %d checks passed. You are ready for Module 1.\033[0m\n" "$pass"
  exit 0
else
  printf "\033[31m%d check(s) failed, %d passed. Fix the above before class.\033[0m\n" "$fail" "$pass"
  exit 1
fi

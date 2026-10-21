#!/usr/bin/env bash
# Refresh vendor/mattpocock-skills from upstream and install only the core skills.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="${ROOT}/vendor/mattpocock-skills"
SKILLS_DEST="${ROOT}/.cursor/skills"
CORE_LIST="${ROOT}/scripts/core-skills.txt"
MANAGED_STAMP="${SKILLS_DEST}/.core-skills-managed"
UPSTREAM_URL="https://github.com/mattpocock/skills.git"
UPSTREAM_BRANCH="main"

if [[ ! -f "${CORE_LIST}" ]]; then
  echo "error: missing core skill list: ${CORE_LIST}" >&2
  exit 1
fi

mapfile -t CORE_SKILLS < <(grep -vE '^\s*(#|$)' "${CORE_LIST}" | sed 's/[[:space:]]*$//')
if [[ ${#CORE_SKILLS[@]} -eq 0 ]]; then
  echo "error: ${CORE_LIST} has no skill names" >&2
  exit 1
fi

mkdir -p "${ROOT}/vendor" "${SKILLS_DEST}"

if [[ ! -d "${VENDOR_DIR}/.git" ]]; then
  echo "Cloning ${UPSTREAM_URL} → ${VENDOR_DIR}"
  git clone --depth 1 --branch "${UPSTREAM_BRANCH}" "${UPSTREAM_URL}" "${VENDOR_DIR}"
else
  echo "Updating ${VENDOR_DIR}"
  git -C "${VENDOR_DIR}" fetch origin "${UPSTREAM_BRANCH}"
  git -C "${VENDOR_DIR}" checkout "${UPSTREAM_BRANCH}"
  git -C "${VENDOR_DIR}" pull --ff-only origin "${UPSTREAM_BRANCH}"
fi

UPSTREAM_SHA="$(git -C "${VENDOR_DIR}" rev-parse HEAD)"
echo "Upstream SHA: ${UPSTREAM_SHA}"

find_skill_src() {
  local name="$1"
  local candidate
  for candidate in \
    "${VENDOR_DIR}/skills/engineering/${name}" \
    "${VENDOR_DIR}/skills/productivity/${name}"; do
    if [[ -d "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return 0
    fi
  done
  # Fallback: any skills/**/<name>/ directory
  candidate="$(find "${VENDOR_DIR}/skills" -type d -name "${name}" 2>/dev/null | head -n 1 || true)"
  if [[ -n "${candidate}" ]]; then
    printf '%s' "${candidate}"
    return 0
  fi
  return 1
}

declare -A INSTALLED=()
MISSING=()

for name in "${CORE_SKILLS[@]}"; do
  src="$(find_skill_src "${name}" || true)"
  if [[ -z "${src}" ]]; then
    MISSING+=("${name}")
    echo "warn: skill not found upstream: ${name}" >&2
    continue
  fi
  dest="${SKILLS_DEST}/${name}"
  rm -rf "${dest}"
  mkdir -p "${dest}"
  cp -a "${src}/." "${dest}/"
  INSTALLED["${name}"]=1
  rel="${src#"$VENDOR_DIR"/}"
  echo "Installed ${name} ← ${rel}"
done

# Remove previously synced core skill dirs that are no longer in the list.
# Only touch names this script previously managed — never delete unrelated
# .cursor/ content such as rules/ or user-added skills.
PREV_MANAGED=()
if [[ -f "${MANAGED_STAMP}" ]]; then
  mapfile -t PREV_MANAGED < <(grep -vE '^\s*(#|$)' "${MANAGED_STAMP}" || true)
fi

is_current_core() {
  local candidate="$1"
  local s
  for s in "${CORE_SKILLS[@]}"; do
    [[ "${s}" == "${candidate}" ]] && return 0
  done
  return 1
}

for prev in "${PREV_MANAGED[@]:-}"; do
  [[ -z "${prev}" ]] && continue
  if ! is_current_core "${prev}"; then
    if [[ -d "${SKILLS_DEST}/${prev}" ]]; then
      rm -rf "${SKILLS_DEST}/${prev}"
      echo "Removed stale core skill: ${prev}"
    fi
  fi
done

: > "${MANAGED_STAMP}"
for name in "${CORE_SKILLS[@]}"; do
  if [[ -n ${INSTALLED[$name]+x} ]]; then
    printf '%s\n' "${name}" >> "${MANAGED_STAMP}"
  fi
done

echo
echo "=== Sync summary ==="
echo "Upstream: ${UPSTREAM_URL}"
echo "SHA:      ${UPSTREAM_SHA}"
echo "Installed:"
for name in "${CORE_SKILLS[@]}"; do
  if [[ -n ${INSTALLED[$name]+x} ]]; then
    echo "  - ${name}"
  fi
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Missing upstream:"
  for name in "${MISSING[@]}"; do
    echo "  - ${name}"
  done
  exit 1
fi

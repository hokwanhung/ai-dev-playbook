#!/usr/bin/env bash
# Refresh vendor/mattpocock-skills at the pinned SHA and install only the core skills.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="${ROOT}/vendor/mattpocock-skills"
SKILLS_DEST="${ROOT}/.cursor/skills"
CORE_LIST="${ROOT}/scripts/core-skills.txt"
PIN_FILE="${ROOT}/scripts/upstream-sha.txt"
MANAGED_STAMP="${SKILLS_DEST}/.core-skills-managed"
UPSTREAM_URL="https://github.com/mattpocock/skills.git"

if [[ ! -f "${CORE_LIST}" ]]; then
  echo "error: missing core skill list: ${CORE_LIST}" >&2
  exit 1
fi

if [[ ! -f "${PIN_FILE}" ]]; then
  echo "error: missing upstream pin: ${PIN_FILE}" >&2
  exit 1
fi

PINNED_SHA="$(tr -d '[:space:]' < "${PIN_FILE}")"
if [[ ! "${PINNED_SHA}" =~ ^[0-9a-fA-F]{40}$ ]]; then
  echo "error: ${PIN_FILE} must contain a 40-char hex SHA (got: '${PINNED_SHA}')" >&2
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
  git clone --filter=blob:none --no-checkout "${UPSTREAM_URL}" "${VENDOR_DIR}"
fi

CURRENT_SHA="$(git -C "${VENDOR_DIR}" rev-parse HEAD 2>/dev/null || true)"
if [[ "${CURRENT_SHA}" != "${PINNED_SHA}" ]]; then
  echo "Fetching pinned SHA ${PINNED_SHA}"
  git -C "${VENDOR_DIR}" fetch --depth 1 origin "${PINNED_SHA}"
  git -C "${VENDOR_DIR}" checkout --force "${PINNED_SHA}"
else
  echo "Vendor already at pinned SHA ${PINNED_SHA}"
fi

UPSTREAM_SHA="$(git -C "${VENDOR_DIR}" rev-parse HEAD)"
if [[ "${UPSTREAM_SHA}" != "${PINNED_SHA}" ]]; then
  echo "error: vendor HEAD ${UPSTREAM_SHA} does not match pin ${PINNED_SHA}" >&2
  exit 1
fi
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
echo "Pin:      ${PINNED_SHA}"
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

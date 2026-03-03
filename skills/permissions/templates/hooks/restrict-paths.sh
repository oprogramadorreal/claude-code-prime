#!/usr/bin/env bash
# ============================================================================
# restrict-paths.sh — Claude Code PreToolUse hook
# Installed by: /optimus:permissions (optimus-claude plugin)
# Source:       https://github.com/oprogramadorreal/optimus-claude
# Docs:         skills/permissions/README.md
# ============================================================================
#
# PURPOSE:
#   Prevents Claude Code from writing or deleting files outside your project
#   directory. This is a safety guardrail, not a permissions bypass — it adds
#   restrictions, not removes them.
#
# WHAT THIS SCRIPT DOES:
#   - Edit/Write operations inside the project  → silently allowed
#   - Edit/Write operations outside the project → prompts you for approval
#   - rm/rmdir commands outside the project     → hard blocked
#   - Everything else (reads, searches, etc.)   → passes through unchanged
#
# WHAT THIS SCRIPT DOES NOT DO:
#   - Does NOT send data anywhere (no network calls)
#   - Does NOT log or record file paths or commands
#   - Does NOT modify, read, or copy your files
#   - Does NOT run in the background or persist after Claude Code exits
#
# FAIL-OPEN DESIGN:
#   When the hook cannot determine whether an operation is safe (e.g.,
#   CLAUDE_PROJECT_DIR is unset, JSON parsing fails, or the file_path field
#   is missing), it allows the operation rather than blocking it. This avoids
#   breaking legitimate tool use when input formats change.
#
# UNVERSIONED FILE PROTECTION (opt-in):
#   Set OPTIMUS_PROTECT_UNVERSIONED=1 to prompt before modifying or deleting
#   files inside the project that are NOT tracked by git. Unversioned files
#   cannot be recovered after changes. Disabled by default because it also
#   prompts for regenerable files (node_modules, dist, build output).
#   See the skill's README for details and known limitations.
#
# TO DISABLE OR REMOVE:
#   1. Delete this file: rm .claude/hooks/restrict-paths.sh
#   2. Remove the PreToolUse hook entry from .claude/settings.json
#   Or simply ignore it — the hook only runs when Claude Code invokes tools.
# ============================================================================

input=$(cat)

root="${CLAUDE_PROJECT_DIR}"
# Fail-open: if project root is unknown, allow rather than block all tool use
[[ -z "$root" ]] && exit 0

# --- Opt-in unversioned file protection ---
protect_unversioned="${OPTIMUS_PROTECT_UNVERSIONED:-0}"
is_git_repo=false
if [[ "$protect_unversioned" != "0" ]]; then
  git -C "$root" rev-parse --is-inside-work-tree &>/dev/null && is_git_repo=true
fi

is_git_tracked() {
  # Fail-open: if not a git repo or git unavailable, assume tracked (allow)
  # Note: is_git_repo is only populated when protect_unversioned is enabled.
  # Only call this function inside protect_unversioned guards.
  [[ "$is_git_repo" == "true" ]] || return 0
  git -C "$root" ls-files --error-unmatch "$1" &>/dev/null
}

# --- Path normalization (cross-platform) ---
normalize() {
  local p="$1"
  # Convert Windows paths on MSYS/Cygwin
  command -v cygpath &>/dev/null && p="$(cygpath -u "$p" 2>/dev/null || echo "$p")"
  # Resolve ../ traversal without requiring path to exist
  if command -v realpath &>/dev/null; then
    p="$(realpath -m "$p" 2>/dev/null || echo "$p")"
  elif [[ -d "$(dirname "$p")" ]]; then
    p="$(cd "$(dirname "$p")" 2>/dev/null && pwd)/$(basename "$p")"
  fi
  # Case-insensitive on Windows (NTFS)
  [[ "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == cygwin* ]] && p="${p,,}"
  echo "$p"
}

norm_root="$(normalize "$root")"
# Ensure trailing slash for prefix matching (avoids /project-other matching /project)
[[ "$norm_root" != */ ]] && norm_root="${norm_root}/"

is_inside_project() {
  local norm_path
  norm_path="$(normalize "$1")"
  [[ "$norm_path" == "${norm_root}"* || "$norm_path" == "${norm_root%/}" ]]
}

# --- JSON response helpers ---
ask_permission() {
  cat <<JSONEOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"$1"}}
JSONEOF
  exit 0
}

deny_operation() {
  cat <<JSONEOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"$1"}}
JSONEOF
  exit 0
}

# --- Extract tool_name ---
# Fail-open: if tool_name cannot be extracted, allow rather than block
[[ "$input" =~ \"tool_name\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] || exit 0
tool_name="${BASH_REMATCH[1]}"

case "$tool_name" in
  Edit|MultiEdit|Write)
    # Fail-open: if file_path cannot be extracted, allow rather than block
    [[ "$input" =~ \"file_path\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] || exit 0
    filepath="${BASH_REMATCH[1]}"
    if ! is_inside_project "$filepath"; then
      ask_permission "File '$filepath' is outside project root. Allow this write?"
    fi
    # Opt-in: prompt before modifying existing unversioned files
    if [[ "$protect_unversioned" != "0" && -e "$filepath" ]] && ! is_git_tracked "$filepath"; then
      ask_permission "File '$filepath' is not tracked by git. Changes cannot be recovered. Allow this write?"
    fi
    exit 0
    ;;
  NotebookEdit)
    # Fail-open: if notebook_path cannot be extracted, allow rather than block
    [[ "$input" =~ \"notebook_path\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] || exit 0
    filepath="${BASH_REMATCH[1]}"
    if ! is_inside_project "$filepath"; then
      ask_permission "Notebook '$filepath' is outside project root. Allow this edit?"
    fi
    # Opt-in: prompt before modifying existing unversioned notebooks
    if [[ "$protect_unversioned" != "0" && -e "$filepath" ]] && ! is_git_tracked "$filepath"; then
      ask_permission "Notebook '$filepath' is not tracked by git. Changes cannot be recovered. Allow this edit?"
    fi
    exit 0
    ;;
  Bash)
    # Fail-open: if command cannot be extracted, allow rather than block
    [[ "$input" =~ \"command\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] || exit 0
    cmd="${BASH_REMATCH[1]}"
    # Only intercept rm/rmdir commands (best-effort delete protection)
    [[ "$cmd" =~ ^(rm|rmdir)[[:space:]] ]] || exit 0
    # Use read -ra to properly split into an array (handles the command as shell words)
    read -ra words <<< "$cmd"
    for word in "${words[@]}"; do
      [[ "$word" == rm || "$word" == rmdir || "$word" == -* ]] && continue
      if ! is_inside_project "$word"; then
        deny_operation "BLOCKED: Cannot delete '$word' — outside project root."
      fi
      # Opt-in: prompt before deleting unversioned files inside the project
      if [[ "$protect_unversioned" != "0" && -e "$word" ]] && is_inside_project "$word" && ! is_git_tracked "$word"; then
        ask_permission "File '$word' is not tracked by git. Deletion is permanent. Allow?"
      fi
    done
    exit 0
    ;;
  *)
    exit 0
    ;;
esac

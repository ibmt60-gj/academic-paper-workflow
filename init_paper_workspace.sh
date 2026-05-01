#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  ./init_paper_workspace.sh [--mode confirm|auto] "论文题目"

Examples:
  ./init_paper_workspace.sh "论文题目"
  ./init_paper_workspace.sh --mode confirm "论文题目"
  ./init_paper_workspace.sh --mode auto "论文题目"
EOF
}

normalize_execution_mode() {
  case "$1" in
    "confirm"|"逐步确认")
      printf '%s\n' "逐步确认"
      ;;
    "auto"|"自动执行")
      printf '%s\n' "自动执行"
      ;;
    *)
      return 1
      ;;
  esac
}

EXECUTION_MODE="逐步确认"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      if [[ $# -lt 2 ]]; then
        echo "Error: --mode requires a value." >&2
        usage
        exit 1
      fi
      EXECUTION_MODE="$(normalize_execution_mode "$2")" || {
        echo "Error: invalid mode: $2" >&2
        echo "Allowed values: confirm, auto" >&2
        exit 1
      }
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TITLE="$1"
WORKFLOW_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNS_DIR="$WORKFLOW_DIR/paper_runs"
TEMPLATE_DIR="$WORKFLOW_DIR/templates"
INIT_TIME="$(date '+%Y-%m-%d %H:%M:%S %z')"
INIT_SUCCESS=0

sanitize_title() {
  printf '%s' "$1" \
    | tr '[:space:]' '_' \
    | sed 's#[/:：\\*?"<>|]#_#g; s/_\+/_/g; s/^_//; s/_$//'
}

render_template() {
  local src="$1"
  local dst="$2"

  if [[ ! -f "$src" ]]; then
    echo "Error: template not found: $src" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$dst")"

  PAPER_TITLE="$TITLE" \
  PAPER_SLUG="$SLUG" \
  WRITING_EXECUTION_MODE="$EXECUTION_MODE" \
  WORKFLOW_DIR="$WORKFLOW_DIR" \
  INIT_TIME="$INIT_TIME" \
  "$PYTHON_BIN" - "$src" "$dst" <<'PY'
import os
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])

text = src.read_text(encoding="utf-8")
replacements = {
    "{{PAPER_TITLE}}": os.environ["PAPER_TITLE"],
    "{{PAPER_SLUG}}": os.environ["PAPER_SLUG"],
    "{{WRITING_EXECUTION_MODE}}": os.environ["WRITING_EXECUTION_MODE"],
    "{{WORKFLOW_DIR}}": os.environ["WORKFLOW_DIR"],
    "{{INIT_TIME}}": os.environ["INIT_TIME"],
}

for key, value in replacements.items():
    text = text.replace(key, value)

dst.write_text(text, encoding="utf-8")
PY
}

SLUG="$(sanitize_title "$TITLE")"

if [[ -z "$SLUG" ]]; then
  echo "Error: title becomes empty after normalization." >&2
  exit 1
fi

PAPER_DIR="$RUNS_DIR/$SLUG"
TMP_DIR="$RUNS_DIR/.${SLUG}.tmp.$$"

if [[ -e "$PAPER_DIR" ]]; then
  echo "Workspace already exists: $PAPER_DIR" >&2
  exit 1
fi

PYTHON_BIN="$(command -v python3 || true)"
if [[ -z "$PYTHON_BIN" ]]; then
  echo "Error: python3 is required to render templates but was not found." >&2
  exit 1
fi

REQUIRED_TEMPLATES=(
  "$TEMPLATE_DIR/run_info.md"
  "$TEMPLATE_DIR/input/outline.md"
  "$TEMPLATE_DIR/input/writing_requirements.md"
  "$TEMPLATE_DIR/materials/source_materials_readme.md"
  "$TEMPLATE_DIR/materials/reference_leads.md"
  "$TEMPLATE_DIR/materials/source_index.md"
  "$TEMPLATE_DIR/materials/materials_understanding.md"
)

for required_template in "${REQUIRED_TEMPLATES[@]}"; do
  if [[ ! -f "$required_template" ]]; then
    echo "Error: required template not found: $required_template" >&2
    exit 1
  fi
done

STEP_TEMPLATES=()
for template_path in "$TEMPLATE_DIR"/steps/*/*; do
  if [[ -f "$template_path" ]]; then
    STEP_TEMPLATES+=("$template_path")
  fi
done

if [[ "${#STEP_TEMPLATES[@]}" -eq 0 ]]; then
  echo "Error: no step templates found under: $TEMPLATE_DIR/steps" >&2
  exit 1
fi

if [[ -e "$TMP_DIR" ]]; then
  echo "Error: temporary workspace already exists: $TMP_DIR" >&2
  exit 1
fi

cleanup_tmp_dir() {
  if [[ "$INIT_SUCCESS" -ne 1 && -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}

trap cleanup_tmp_dir EXIT

mkdir -p "$RUNS_DIR"

mkdir -p \
  "$TMP_DIR/00_source_materials/references" \
  "$TMP_DIR/00_source_materials/notes" \
  "$TMP_DIR/00_source_materials/cases" \
  "$TMP_DIR/00_source_materials/data" \
  "$TMP_DIR/00_source_materials/images" \
  "$TMP_DIR/00_source_materials/materials_understanding" \
  "$TMP_DIR/01_outline_normalization" \
  "$TMP_DIR/02_section_goals" \
  "$TMP_DIR/03_evidence_sources" \
  "$TMP_DIR/04_paragraph_skeleton" \
  "$TMP_DIR/05_draft" \
  "$TMP_DIR/06_structural_revision" \
  "$TMP_DIR/07_references_integration" \
  "$TMP_DIR/08_final_submission"

render_template "$TEMPLATE_DIR/run_info.md" "$TMP_DIR/RUN_INFO.md"
render_template "$TEMPLATE_DIR/input/outline.md" "$TMP_DIR/outline.md"
render_template "$TEMPLATE_DIR/input/writing_requirements.md" "$TMP_DIR/writing_requirements.md"
render_template "$TEMPLATE_DIR/materials/source_materials_readme.md" "$TMP_DIR/00_source_materials/README.md"
render_template "$TEMPLATE_DIR/materials/reference_leads.md" "$TMP_DIR/00_source_materials/reference_leads.md"
render_template "$TEMPLATE_DIR/materials/source_index.md" "$TMP_DIR/00_source_materials/source_index.md"
render_template "$TEMPLATE_DIR/materials/materials_understanding.md" "$TMP_DIR/00_source_materials/materials_understanding/materials_understanding.md"

for template_path in "${STEP_TEMPLATES[@]}"; do
  rel_path="${template_path#"$TEMPLATE_DIR/steps/"}"
  render_template "$template_path" "$TMP_DIR/$rel_path"
done

bash "$WORKFLOW_DIR/update_progress.sh" "$TMP_DIR" "Phase 0" "启动阶段已完成，待进入输入准备阶段" "下一步：进入输入准备阶段，放入资料，并填写 outline.md 与 writing_requirements.md" >/dev/null

if [[ -e "$PAPER_DIR" ]]; then
  echo "Workspace already exists after initialization started: $PAPER_DIR" >&2
  exit 1
fi

mv "$TMP_DIR" "$PAPER_DIR"
INIT_SUCCESS=1

echo "Created paper workspace:"
echo "$PAPER_DIR"

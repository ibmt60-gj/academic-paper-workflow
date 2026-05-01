#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  bash ./export_final_docx.sh [--preview] "<paper_dir>"

Example:
  bash ./export_final_docx.sh "paper_runs/示例论文"
  bash ./export_final_docx.sh --preview "paper_runs/示例论文"

Input:
  <paper_dir>/08_final_submission/final_submission.md

Output:
  Default:
    <paper_dir>/08_final_submission/final_submission.docx
  Preview:
    <paper_dir>/08_final_submission/final_submission_preview.docx
EOF
}

WORKFLOW_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$WORKFLOW_DIR/quality_review_utils.sh"
PREVIEW_MODE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preview)
      PREVIEW_MODE=1
      shift
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

PAPER_DIR="$1"

find_python_with_docx() {
  local candidates=(
    "/opt/anaconda3/bin/python3"
    "/opt/anaconda3/bin/python"
    "python3"
    "python"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      if "$candidate" -c 'import docx' >/dev/null 2>&1; then
        printf '%s' "$candidate"
        return 0
      fi
    fi
  done

  return 1
}

if [[ "$PAPER_DIR" != /* ]]; then
  PAPER_DIR="$WORKFLOW_DIR/$PAPER_DIR"
fi

INPUT="$PAPER_DIR/08_final_submission/final_submission.md"
QUALITY_REVIEW="$PAPER_DIR/08_final_submission/quality_review.md"
if [[ "$PREVIEW_MODE" -eq 1 ]]; then
  OUTPUT="$PAPER_DIR/08_final_submission/final_submission_preview.docx"
else
  OUTPUT="$PAPER_DIR/08_final_submission/final_submission.docx"
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: final markdown not found: $INPUT" >&2
  exit 1
fi

if grep -q "^## 本步骤资料使用记录" "$INPUT" \
  || grep -q "^## 本步骤写作要求使用记录" "$INPUT" \
  || grep -q "^## 本步骤质量增强文件使用记录" "$INPUT" \
  || grep -q "^状态：" "$INPUT" \
  || grep -q "^# Step 8:" "$INPUT"; then
  echo "Error: final_submission.md still contains workflow/process records." >&2
  echo "Move Step 8 records to step8_record.md before exporting Word." >&2
  exit 1
fi

if [[ "$PREVIEW_MODE" -ne 1 ]]; then
  if [[ ! -f "$QUALITY_REVIEW" ]]; then
    echo "Error: quality review file not found: $QUALITY_REVIEW" >&2
    echo "Formal export requires a completed quality_review.md. Use --preview only when the user explicitly asks for a preview Word file." >&2
    exit 1
  fi

  if grep -q "^状态：待开始" "$QUALITY_REVIEW"; then
    echo "Error: quality_review.md is still in template state." >&2
    echo "Formal export requires a completed quality review. Use --preview only when the user explicitly asks for a preview Word file." >&2
    exit 1
  fi

  quality_ready="$(read_quality_review_ready_value "$QUALITY_REVIEW")"
  quality_ready="$(trim_quality_review_value "$quality_ready")"

  if [[ -z "$quality_ready" ]]; then
    echo "Error: quality_review.md does not state whether the manuscript has reached submission-ready status." >&2
    echo "Fill '是否已经达到可提交状态' before formal export." >&2
    exit 1
  fi

  if quality_review_is_negative "$quality_ready"; then
    echo "Error: quality_review.md explicitly indicates the manuscript has not reached submission-ready status: $quality_ready" >&2
    echo "Only use formal export after the manuscript is judged submission-ready. Use --preview only when the user explicitly asks for a preview Word file." >&2
    exit 1
  fi

  if ! quality_review_is_positive "$quality_ready"; then
    echo "Error: quality_review.md must clearly state that the manuscript is submission-ready before formal export." >&2
    echo "Recommended wording: 是 / 已达到可提交状态" >&2
    exit 1
  fi
fi

if command -v pandoc >/dev/null 2>&1; then
  pandoc "$INPUT" -o "$OUTPUT"
  if [[ "$PREVIEW_MODE" -eq 1 ]]; then
    echo "Created preview Word file with pandoc:"
  else
    echo "Created formal Word file with pandoc:"
  fi
  echo "$OUTPUT"
  exit 0
fi

FALLBACK="$WORKFLOW_DIR/markdown_to_docx.py"

if [[ ! -f "$FALLBACK" ]]; then
  echo "Error: pandoc was not found and fallback exporter is missing: $FALLBACK" >&2
  exit 1
fi

PYTHON_WITH_DOCX="$(find_python_with_docx || true)"
if [[ -z "$PYTHON_WITH_DOCX" ]]; then
  echo "Error: pandoc was not found and no Python environment with python-docx was found." >&2
  echo "Install pandoc or install python-docx, then rerun this script." >&2
  exit 1
fi

"$PYTHON_WITH_DOCX" "$FALLBACK" "$INPUT" "$OUTPUT"
if [[ "$PREVIEW_MODE" -eq 1 ]]; then
  echo "Created preview Word file with python-docx fallback:"
else
  echo "Created formal Word file with python-docx fallback:"
fi
echo "$OUTPUT"

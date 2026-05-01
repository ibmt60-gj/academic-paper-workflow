#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  bash ./validate_workflow.sh [--strict] "<paper_dir>"

Example:
  bash ./validate_workflow.sh "paper_runs/示例论文"
  bash ./validate_workflow.sh --strict "paper_runs/示例论文"

Options:
  --strict  Treat content warnings as validation failures.
EOF
}

STRICT=0

if [[ "${1:-}" == "--strict" ]]; then
  STRICT=1
  shift
fi

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

WORKFLOW_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$WORKFLOW_DIR/quality_review_utils.sh"
PAPER_DIR="$1"

if [[ "$PAPER_DIR" != /* ]]; then
  PAPER_DIR="$WORKFLOW_DIR/$PAPER_DIR"
fi

missing=0
warnings=0

STEP_FILES=(
  "01_outline_normalization/normalized_outline.md"
  "02_section_goals/section_goals.md"
  "03_evidence_sources/evidence_sources.md"
  "04_paragraph_skeleton/paragraph_skeleton.md"
  "05_draft/draft.md"
  "06_structural_revision/structural_revision.md"
  "07_references_integration/references_integration.md"
  "08_final_submission/step8_record.md"
)

STEP_QUALITY_AUX_FILES=(
  "1|01_outline_normalization/contribution_statement.md"
  "2|02_section_goals/literature_position_matrix.md"
  "3|03_evidence_sources/claim_evidence_inference_cards.md"
  "8|08_final_submission/quality_review.md"
)

check_path() {
  local path="$1"
  if [[ ! -e "$PAPER_DIR/$path" ]]; then
    echo "MISSING: $path"
    missing=1
  else
    echo "OK:      $path"
  fi
}

check_optional_path() {
  local path="$1"
  if [[ -e "$PAPER_DIR/$path" ]]; then
    echo "OK:      $path"
  else
    echo "SKIP:    $path (optional)"
  fi
}

warn() {
  echo "WARN:    $1"
  warnings=1
}

check_file_contains() {
  local path="$1"
  local pattern="$2"
  local message="$3"

  if [[ -f "$PAPER_DIR/$path" ]] && ! grep -q "$pattern" "$PAPER_DIR/$path"; then
    warn "$message"
  fi
}

check_labeled_value_nonempty() {
  local path="$1"
  local label="$2"
  local message="$3"
  local value
  local trimmed

  if [[ ! -f "$PAPER_DIR/$path" ]]; then
    return
  fi

  value="$(
    awk -v label="- $label" '
      index($0, label) == 1 {
        print substr($0, length(label) + 1)
        exit
      }
    ' "$PAPER_DIR/$path"
  )"

  trimmed="$(printf '%s' "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

  if [[ -z "$trimmed" ]]; then
    warn "$message"
  fi
}

check_any_labeled_value_nonempty() {
  local path="$1"
  local message="$2"
  shift 2

  local label
  local value
  local trimmed

  if [[ ! -f "$PAPER_DIR/$path" ]]; then
    return
  fi

  for label in "$@"; do
    value="$(
      awk -v label="- $label" '
        index($0, label) == 1 {
          print substr($0, length(label) + 1)
          exit
        }
      ' "$PAPER_DIR/$path"
    )"
    trimmed="$(printf '%s' "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    if [[ -n "$trimmed" ]]; then
      return
    fi
  done

  warn "$message"
}

check_template_marker() {
  local path="$1"
  local marker="$2"
  local message="$3"

  if [[ -f "$PAPER_DIR/$path" ]] && grep -q "$marker" "$PAPER_DIR/$path"; then
    warn "$message"
  fi
}

check_execution_mode() {
  local run_info="$PAPER_DIR/RUN_INFO.md"
  local mode

  if [[ ! -f "$run_info" ]]; then
    return
  fi

  mode="$(sed -n 's/^- 输入完成后执行模式：//p' "$run_info" | head -n 1)"

  if [[ -z "$mode" ]]; then
    mode="$(sed -n 's/^- 正式写作执行模式：//p' "$run_info" | head -n 1)"
  fi

  if [[ -z "$mode" ]]; then
    warn "RUN_INFO.md is missing an execution mode after inputs are ready. Expected: 逐步确认 or 自动执行."
  elif [[ "$mode" != "逐步确认" && "$mode" != "自动执行" ]]; then
    warn "RUN_INFO.md contains an invalid execution mode after inputs are ready: $mode"
  fi
}

read_current_marker() {
  local progress_path="$PAPER_DIR/progress.md"

  if [[ ! -f "$progress_path" ]]; then
    return
  fi

  sed -n 's/^- 当前阶段\/步骤：//p' "$progress_path" | head -n 1
}

resolve_outline_path() {
  if [[ -f "$PAPER_DIR/outline.md" ]]; then
    printf '%s\n' "outline.md"
  elif [[ -f "$PAPER_DIR/outline_input.md" ]]; then
    printf '%s\n' "outline_input.md"
  fi

  return 0
}

read_current_step_number() {
  local marker
  marker="$(read_current_marker)"

  if [[ "$marker" =~ ^Step[[:space:]]+([0-9]+)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  fi

  return 0
}

highest_started_step_number() {
  local idx path

  for (( idx=${#STEP_FILES[@]}; idx>=1; idx-- )); do
    path="${STEP_FILES[$((idx - 1))]}"
    if [[ -f "$PAPER_DIR/$path" ]] && ! grep -q "状态：待开始" "$PAPER_DIR/$path"; then
      printf '%s\n' "$idx"
      return
    fi
  done

  return 0
}

expected_completed_step_number() {
  local current_step started_step
  current_step="${1:-0}"
  started_step="${2:-0}"

  if (( started_step > current_step )); then
    printf '%s\n' "$started_step"
  else
    printf '%s\n' "$current_step"
  fi
}

check_step_not_template() {
  local path="$1"
  local step_num="$2"

  if [[ -f "$PAPER_DIR/$path" ]] && grep -q "状态：待开始" "$PAPER_DIR/$path"; then
    warn "$path still appears to be an unstarted template, but Step $step_num should already have been executed."
  fi
}

require_final_docx() {
  local docx_path="$PAPER_DIR/08_final_submission/final_submission.docx"
  local ready_value
  local trimmed

  if [[ -f "$docx_path" ]]; then
    return 0
  fi

  ready_value="$(read_quality_review_ready_value "$PAPER_DIR/08_final_submission/quality_review.md")"
  trimmed="$(trim_quality_review_value "$ready_value")"

  if [[ -n "$trimmed" ]] && quality_review_is_positive "$trimmed"; then
    return 0
  fi

  return 1
}

check_final_submission_clean() {
  local path="08_final_submission/final_submission.md"

  if [[ ! -f "$PAPER_DIR/$path" ]]; then
    return
  fi

  if grep -q "^## 本步骤资料使用记录" "$PAPER_DIR/$path" \
    || grep -q "^## 本步骤写作要求使用记录" "$PAPER_DIR/$path" \
    || grep -q "^## 本步骤质量增强文件使用记录" "$PAPER_DIR/$path" \
    || grep -q "^状态：" "$PAPER_DIR/$path" \
    || grep -q "^# Step 8:" "$PAPER_DIR/$path"; then
    warn "08_final_submission/final_submission.md still contains workflow/process records and is not clean enough for submission export."
  fi
}

check_quality_review_gate() {
  local quality_review="08_final_submission/quality_review.md"
  local docx_path="$PAPER_DIR/08_final_submission/final_submission.docx"
  local ready_value
  local trimmed

  if (( EXPECTED_STEP_NUM < 8 )) && [[ ! -f "$docx_path" ]]; then
    return
  fi

  if [[ ! -f "$PAPER_DIR/$quality_review" ]]; then
    warn "$quality_review is missing. Step 8 formal export requires a completed quality review."
    return
  fi

  if grep -q "^状态：待开始" "$PAPER_DIR/$quality_review"; then
    warn "$quality_review is still in template state. Step 8 formal export requires a completed quality review."
    return
  fi

  ready_value="$(read_quality_review_ready_value "$PAPER_DIR/08_final_submission/quality_review.md")"
  trimmed="$(trim_quality_review_value "$ready_value")"

  if [[ -z "$trimmed" ]]; then
    warn "$quality_review is missing a filled value for '是否已经达到可提交状态'."
    return
  fi

  if quality_review_is_negative "$trimmed"; then
    warn "$quality_review indicates the manuscript is not yet submission-ready: $trimmed"
    return
  fi

  if ! quality_review_is_positive "$trimmed"; then
    warn "$quality_review should clearly state a positive submission-ready conclusion, for example: 是 / 已达到可提交状态."
  fi
}

check_outline_content() {
  local path="$1"

  if [[ ! -f "$PAPER_DIR/$path" ]]; then
    return
  fi

  local title_line outline_count

  title_line="$(
    awk '
      /^## 1\. 论文题目/ {
        while (getline > 0) {
          if ($0 ~ /^[[:space:]]*$/) {
            continue
          }
          print $0
          exit
        }
      }
    ' "$PAPER_DIR/$path"
  )"

  outline_count="$(
    awk '
      BEGIN { in_outline=0; count=0 }
      /^## 2\. 论文大纲/ { in_outline=1; next }
      /^## / {
        if (in_outline) {
          exit
        }
      }
      {
        if (in_outline && $0 ~ /^[[:space:]]*[0-9]+([.][0-9]+)?[[:space:]]+[^[:space:]]/ && $0 !~ /\[[^]]+\]/) {
          count++
        }
      }
      END { print count }
    ' "$PAPER_DIR/$path"
  )"

  if [[ -z "$title_line" || "$title_line" == "{{PAPER_TITLE}}" ]]; then
    warn "$path appears to be missing a real paper title."
  fi

  if [[ "${outline_count:-0}" -eq 0 ]]; then
    warn "$path appears to be missing actual outline entries."
  fi
}

if [[ ! -d "$PAPER_DIR" ]]; then
  echo "Error: paper directory not found: $PAPER_DIR" >&2
  exit 1
fi

OUTLINE_PATH="$(resolve_outline_path)"

echo "Validating paper workflow:"
echo "$PAPER_DIR"
echo

check_path "RUN_INFO.md"
if [[ -n "$OUTLINE_PATH" ]]; then
  echo "OK:      $OUTLINE_PATH"
else
  echo "MISSING: outline.md (or legacy outline_input.md)"
  missing=1
fi
check_path "writing_requirements.md"
check_path "progress.md"
check_path "00_source_materials"
check_path "00_source_materials/README.md"
check_optional_path "00_source_materials/reference_leads.md"
check_path "00_source_materials/source_index.md"
check_path "00_source_materials/materials_understanding/materials_understanding.md"
check_path "00_source_materials/references"
check_path "00_source_materials/notes"
check_path "00_source_materials/cases"
check_path "00_source_materials/data"
check_path "00_source_materials/images"
check_path "01_outline_normalization/normalized_outline.md"
check_optional_path "01_outline_normalization/contribution_statement.md"
check_path "02_section_goals/section_goals.md"
check_optional_path "02_section_goals/literature_position_matrix.md"
check_path "03_evidence_sources/evidence_sources.md"
check_optional_path "03_evidence_sources/claim_evidence_inference_cards.md"
check_path "04_paragraph_skeleton/paragraph_skeleton.md"
check_path "05_draft/draft.md"
check_path "06_structural_revision/structural_revision.md"
check_path "07_references_integration/references_integration.md"
check_path "08_final_submission/README.md"
check_path "08_final_submission/final_submission.md"
check_optional_path "08_final_submission/step8_record.md"
check_optional_path "08_final_submission/quality_review.md"

if require_final_docx; then
  check_path "08_final_submission/final_submission.docx"
fi

if [[ "$missing" -ne 0 ]]; then
  echo
  echo "Validation failed: missing required files or directories."
  exit 1
fi

echo
echo "Content checks:"

if [[ -n "$OUTLINE_PATH" ]]; then
  check_outline_content "$OUTLINE_PATH"
fi
check_execution_mode
check_final_submission_clean
check_template_marker "00_source_materials/source_index.md" "状态：待生成" "source_index.md has not been generated yet."
check_template_marker "00_source_materials/materials_understanding/materials_understanding.md" "状态：待开始" "materials_understanding.md has not been completed yet."

CURRENT_STEP_NUM="${CURRENT_STEP_NUM:-0}"
STARTED_STEP_NUM="${STARTED_STEP_NUM:-0}"
CURRENT_STEP_NUM="$(read_current_step_number)"
STARTED_STEP_NUM="$(highest_started_step_number)"
EXPECTED_STEP_NUM="$(expected_completed_step_number "${CURRENT_STEP_NUM:-0}" "${STARTED_STEP_NUM:-0}")"

check_quality_review_gate

for idx in "${!STEP_FILES[@]}"; do
  path="${STEP_FILES[$idx]}"
  if [[ -f "$PAPER_DIR/$path" ]]; then
    check_file_contains "$path" "## 本步骤资料使用记录" "$path is missing material usage record section."
    check_file_contains "$path" "## 本步骤写作要求使用记录" "$path is missing writing requirement usage record section."
    if (( idx >= 1 )); then
      check_file_contains "$path" "## 本步骤质量增强文件使用记录" "$path is missing quality enhancement usage record section."
    fi
  elif (( idx == 7 )); then
    warn "$path is missing. Step 8 should keep process records in step8_record.md."
  fi

  step_num=$((idx + 1))
  if (( step_num <= EXPECTED_STEP_NUM )); then
    check_step_not_template "$path" "$step_num"
    if (( idx >= 1 )) && [[ -f "$PAPER_DIR/$path" ]] && ! grep -q "状态：待开始" "$PAPER_DIR/$path"; then
      check_any_labeled_value_nonempty "$path" "$path is missing a filled value for '本步骤实际读取的质量文件'." \
        "本步骤实际读取的质量文件：" \
        "已读取的质量文件："
      check_labeled_value_nonempty "$path" "本步骤如何继承前置质量约束：" "$path is missing a filled value for '本步骤如何继承前置质量约束'."
      check_labeled_value_nonempty "$path" "本步骤新增了哪些质量澄清或修正：" "$path is missing a filled value for '本步骤新增了哪些质量澄清或修正'."
    fi
  fi
done

for entry in "${STEP_QUALITY_AUX_FILES[@]}"; do
  step_num="${entry%%|*}"
  path="${entry#*|}"

  if (( step_num <= EXPECTED_STEP_NUM )); then
    if [[ -f "$PAPER_DIR/$path" ]]; then
      check_step_not_template "$path" "$step_num"
    else
      warn "$path is missing. Step $step_num should include this quality enhancement artifact."
    fi
  fi
done

if [[ "$warnings" -ne 0 ]]; then
  echo
  if [[ "$STRICT" -eq 1 ]]; then
    echo "Validation failed in strict mode: warnings found."
    exit 2
  fi
  echo "Validation passed with warnings."
else
  echo "OK:      Required content sections are present."
  echo
  echo "Validation passed."
fi

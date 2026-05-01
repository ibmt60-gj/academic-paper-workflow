#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  bash ./update_progress.sh "<paper_dir>" "<current_stage_or_step>" "<current_status>" ["user_todo"]

Examples:
  bash ./update_progress.sh "paper_runs/示例论文" "Phase 1" "输入准备阶段进行中" "请填写 outline.md 和 writing_requirements.md"
  bash ./update_progress.sh "paper_runs/示例论文" "Step 1" "Step 1 已完成，待用户确认" "请确认标准化大纲"
  bash ./update_progress.sh "paper_runs/示例论文" "Step 1" "Step 1 已确认" "等待进入 Step 2"
  bash ./update_progress.sh "paper_runs/示例论文" "Step 8" "Step 8 已确认，工作流完成" "本轮工作流已完成"

Arguments:
  paper_dir              论文任务目录，可以是绝对路径或相对 workflow 根目录的路径
  current_stage_or_step  当前阶段或步骤，例如 Phase 1, Phase 2, Step 1, Step 8
  current_status         当前状态说明
  user_todo              可选，用户待处理事项
EOF
}

validate_marker() {
  local marker="$1"

  case "$marker" in
    "Phase 0"|"Phase 1"|"Phase 2"|"Phase 3"|"Step 1"|"Step 2"|"Step 3"|"Step 4"|"Step 5"|"Step 6"|"Step 7"|"Step 8")
      return 0
      ;;
    *)
      echo "Error: invalid current_stage_or_step: $marker" >&2
      echo "Allowed values: Phase 0, Phase 1, Phase 2, Phase 3, Step 1, Step 2, Step 3, Step 4, Step 5, Step 6, Step 7, Step 8" >&2
      return 1
      ;;
  esac
}

phase_status() {
  local item="$1"
  local label="$2"
  local current="$3"
  local current_status="$4"

  local item_num current_num
  item_num="${item#Phase }"

  if [[ "$current" == Step\ * ]]; then
    if (( item_num < 3 )); then
      printf -- "- %s %s：已完成或已确认" "$item" "$label"
    elif (( item_num == 3 )); then
      printf -- "- %s %s：%s" "$item" "$label" "$(current_item_status_label "$current_status")"
    else
      printf -- "- %s %s：待开始" "$item" "$label"
    fi
    return
  fi

  current_num="${current#Phase }"

  if [[ "$current" == Phase\ * && "$item_num" =~ ^[0-9]+$ && "$current_num" =~ ^[0-9]+$ ]]; then
    if (( item_num < current_num )); then
      printf -- "- %s %s：已完成或已确认" "$item" "$label"
    elif (( item_num == current_num )); then
      printf -- "- %s %s：%s" "$item" "$label" "$(current_item_status_label "$current_status")"
    else
      printf -- "- %s %s：待开始" "$item" "$label"
    fi
  else
    if [[ "$item" == "$current" ]]; then
      printf -- "- %s %s：%s" "$item" "$label" "$(current_item_status_label "$current_status")"
    else
      printf -- "- %s %s：待开始" "$item" "$label"
    fi
  fi
}

step_status() {
  local item="$1"
  local label="$2"
  local current="$3"
  local current_status="$4"

  local item_num current_num phase_num
  item_num="${item#Step }"

  if [[ "$current" == Phase\ * ]]; then
    phase_num="${current#Phase }"
    if [[ "$phase_num" =~ ^[0-9]+$ ]]; then
      if (( item_num == 0 && phase_num >= 0 )); then
        printf -- "- %s %s：已完成或已确认" "$item" "$label"
      else
        printf -- "- %s %s：待开始" "$item" "$label"
      fi
      return
    fi
  fi

  current_num="${current#Step }"

  if [[ "$current" == Step\ * && "$item_num" =~ ^[0-9]+$ && "$current_num" =~ ^[0-9]+$ ]]; then
    if (( item_num < current_num )); then
      printf -- "- %s %s：已完成或已确认" "$item" "$label"
    elif (( item_num == current_num )); then
      printf -- "- %s %s：%s" "$item" "$label" "$(current_item_status_label "$current_status")"
    else
      printf -- "- %s %s：待开始" "$item" "$label"
    fi
  else
    if [[ "$item" == "$current" ]]; then
      printf -- "- %s %s：%s" "$item" "$label" "$(current_item_status_label "$current_status")"
    else
      printf -- "- %s %s：待开始" "$item" "$label"
    fi
  fi
}

current_item_status_label() {
  local current_status="$1"

  if [[ "$current_status" == *"工作流完成"* ]]; then
    printf -- "已确认，工作流完成"
  elif [[ "$current_status" == *"已确认"* ]]; then
    printf -- "已完成或已确认"
  elif [[ "$current_status" == *"已完成"* && "$current_status" == *"待用户确认"* ]]; then
    printf -- "已完成，待用户确认"
  elif [[ "$current_status" == *"已完成"* ]]; then
    printf -- "已完成"
  else
    printf -- "进行中或待确认"
  fi
}

read_execution_mode() {
  local run_info="$1"
  local mode

  if [[ ! -f "$run_info" ]]; then
    return
  fi

  mode="$(sed -n 's/^- 输入完成后执行模式：//p' "$run_info" | head -n 1)"

  if [[ -z "$mode" ]]; then
    mode="$(sed -n 's/^- 正式写作执行模式：//p' "$run_info" | head -n 1)"
  fi

  printf '%s' "$mode"
}

if [[ $# -lt 3 ]]; then
  usage
  exit 1
fi

WORKFLOW_DIR="$(cd "$(dirname "$0")" && pwd)"
PAPER_DIR="$1"
CURRENT_MARKER="$2"
CURRENT_STATUS="$3"
USER_TODO="${4:-等待下一步确认或指令}"

validate_marker "$CURRENT_MARKER"

if [[ "$PAPER_DIR" != /* ]]; then
  PAPER_DIR="$WORKFLOW_DIR/$PAPER_DIR"
fi

if [[ ! -d "$PAPER_DIR" ]]; then
  echo "Error: paper directory not found: $PAPER_DIR" >&2
  exit 1
fi

RUN_INFO="$PAPER_DIR/RUN_INFO.md"
PROGRESS="$PAPER_DIR/progress.md"

if [[ -f "$RUN_INFO" ]]; then
  TITLE="$(sed -n 's/^- 论文题目：//p' "$RUN_INFO" | head -n 1)"
  EXECUTION_MODE="$(read_execution_mode "$RUN_INFO")"
else
  TITLE="$(basename "$PAPER_DIR")"
  EXECUTION_MODE=""
fi

cat > "$PROGRESS" <<EOF
# 论文写作进度

- 论文题目：$TITLE
- 输入完成后执行模式：${EXECUTION_MODE:-未记录}
- 当前状态：$CURRENT_STATUS
- 当前阶段/步骤：$CURRENT_MARKER
- 更新时间：$(date '+%Y-%m-%d %H:%M:%S %z')

## 阶段状态

$(phase_status "Phase 0" "启动阶段" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(phase_status "Phase 1" "输入准备阶段" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(phase_status "Phase 2" "资料理解阶段" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(phase_status "Phase 3" "正式写作阶段" "$CURRENT_MARKER" "$CURRENT_STATUS")

## 步骤状态

$(step_status "Step 1" "明确大纲层级" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(step_status "Step 2" "为每一节定义写作目标" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(step_status "Step 3" "确认每一节的证据和参考来源" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(step_status "Step 4" "搭建段落骨架" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(step_status "Step 5" "撰写内容粗稿" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(step_status "Step 6" "做结构性修订" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(step_status "Step 7" "补充文献与引证" "$CURRENT_MARKER" "$CURRENT_STATUS")
$(step_status "Step 8" "做语言与格式润色，形成可提交稿" "$CURRENT_MARKER" "$CURRENT_STATUS")

## 用户待处理

- $USER_TODO

## 记录说明

- 本文件由 \`update_progress.sh\` 生成
- 每完成一步、用户确认一步或回退修改时，都应更新本文件
- 若状态与实际文件不一致，以各步骤目录中的最新产出文件为准
EOF

echo "Updated progress:"
echo "$PROGRESS"

#!/usr/bin/env bash

read_quality_review_ready_value() {
  local quality_review_path="$1"

  if [[ ! -f "$quality_review_path" ]]; then
    return
  fi

  awk '
    index($0, "- 是否已经达到可提交状态：") == 1 {
      print substr($0, length("- 是否已经达到可提交状态：") + 1)
      exit
    }
  ' "$quality_review_path"
}

trim_quality_review_value() {
  local value="$1"
  printf '%s' "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

quality_review_is_negative() {
  local value="$1"
  [[ "$value" =~ ^(否|未|尚未|未达到|未达|还未|还没有|不能|不可|不可以|暂未|No|NO|no) ]]
}

quality_review_is_positive() {
  local value="$1"
  [[ "$value" =~ ^(是|已达到|达到|可提交|可以提交|基本达到) ]]
}

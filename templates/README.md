# templates 目录说明

`templates/` 只保存空白模板，不保存任何具体论文的已完成产出。

目录分工：

- `input/`：用户输入模板，包括 `outline.md` 和 `writing_requirements.md`
- `materials/`：资料目录说明、文献线索输入、资料理解索引和资料理解阶段产出模板
- `steps/`：Step 1 到 Step 8 的空白产出模板，以及质量增强辅助文件与 Step 8 执行记录模板
- `run_info.md`：单篇论文任务信息模板

使用规则：

- `init_paper_workspace.sh` 会从本目录复制并渲染模板
- 模板中的 `{{PAPER_TITLE}}`、`{{PAPER_SLUG}}`、`{{WRITING_EXECUTION_MODE}}`、`{{WORKFLOW_DIR}}` 和 `{{INIT_TIME}}` 会在初始化时替换
- 具体论文的过程产出只能写入 `paper_runs/<论文题目>/`
- workflow 调试、脚本验收和临时验证产生的测试目录应放入 `archive/test_runs/`，不要与真实论文任务混放
- 历史迁移产出应放入 `archive/legacy_step_outputs/`

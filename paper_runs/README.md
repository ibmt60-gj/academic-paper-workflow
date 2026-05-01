# paper_runs 目录说明

`paper_runs/` 用于保存每一次独立的论文写作任务。

规则：

- 一个论文任务对应一个独立文件夹
- 文件夹名称使用“论文题目规范化”形式
- 不在不同论文任务之间复用同一组输出文件
- workflow 调试、脚本验收和临时验证产生的测试目录，不应放在 `paper_runs/`，应统一移入 `archive/test_runs/`

每个论文文件夹都应包含：

- `RUN_INFO.md`
- `00_source_materials/`
- `00_source_materials/reference_leads.md`
- `00_source_materials/source_index.md`
- `00_source_materials/materials_understanding/materials_understanding.md`
- `outline.md`
- `writing_requirements.md`
- `progress.md`
- `01_outline_normalization/`
- `01_outline_normalization/contribution_statement.md`
- `02_section_goals/`
- `02_section_goals/literature_position_matrix.md`
- `03_evidence_sources/`
- `03_evidence_sources/claim_evidence_inference_cards.md`
- `04_paragraph_skeleton/`
- `05_draft/`
- `06_structural_revision/`
- `07_references_integration/`
- `08_final_submission/`
- `08_final_submission/step8_record.md`
- `08_final_submission/quality_review.md`

最终交付物：

- `08_final_submission/final_submission.docx`

辅助保留：

- `08_final_submission/final_submission.md`
- `08_final_submission/step8_record.md`
- `08_final_submission/quality_review.md`

补充说明：

- 默认导出 `final_submission.docx` 视为正式导出，要求 `quality_review.md` 已完成
- 只有在用户明确要求“先看一版 Word”时，才额外导出 `08_final_submission/final_submission_preview.docx`
- 预览导出不计入工作流正式完成态

执行新任务时：

1. 用户一旦给出论文题目，立即进入启动阶段并执行初始化动作
2. 先新建论文文件夹
3. 再创建 `00_source_materials/` 及其子目录
4. 告知用户启动阶段已完成
5. 确认 `RUN_INFO.md` 中的输入完成后执行模式是 `逐步确认` 还是 `自动执行`
6. 进入输入准备阶段，提醒用户放资料、填写大纲和写作要求；若只有引文信息或链接，也可填写 `00_source_materials/reference_leads.md`
7. 用户不需要指定资料用于哪个章节或步骤
8. 然后读取 `outline.md`、`writing_requirements.md`、`00_source_materials/` 和 `reference_leads.md`
9. 如存在文献线索，由助手主动检索并补充到资料理解流程
10. 由助手维护 `source_index.md`
11. Step 1 需形成 `contribution_statement.md`
12. Step 2 需形成 `literature_position_matrix.md`
13. Step 3 需形成 `claim_evidence_inference_cards.md`
14. Step 8 需形成 `quality_review.md`
15. 用户确认“输入已准备好”后，按 `RUN_INFO.md` 中的执行模式推进资料理解阶段与 Step 1 到 Step 8
16. 若为 `自动执行`，助手默认不中途暂停；但遇到重大歧义、关键资料缺口或会显著改变论文方向的分歧时，仍应暂停一次确认

正确顺序不是：

- 先开始写 Step 1，再补建目录

正确顺序必须是：

- 先建目录
- 再进入输入准备阶段
- 放资料、给大纲、给写作要求
- 助手理解和分配资料用途
- 再开始写

建议的最小启动输入：

- 论文题目

只要有题目，就足够先初始化论文工作区。

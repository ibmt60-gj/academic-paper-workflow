# Step 8 输出说明

本步骤最终应包含：

- `final_submission.md`：Markdown 版终稿，只保留可提交正文
- `final_submission.docx`：Word 版最终提交稿
- `quality_review.md`：终稿质量评分表与导出前复核记录
- `step8_record.md`：Step 8 的流程记录与质量继承记录

导出 Word 文件：

```bash
cd {{WORKFLOW_DIR}}
bash ./export_final_docx.sh "paper_runs/{{PAPER_SLUG}}"
```

只有在用户明确要求预览稿时，才使用：

```bash
cd {{WORKFLOW_DIR}}
bash ./export_final_docx.sh --preview "paper_runs/{{PAPER_SLUG}}"
```

注意：

- 优先使用 Pandoc 导出 Word 文件
- 如果未安装 Pandoc，则使用本工作流内置的 `python-docx` 备用导出器
- 备用导出器适合基础论文结构，复杂表格、脚注、交叉引用和定制样式仍建议使用 Pandoc
- 正式导出前必须完成 `quality_review.md`
- 预览导出生成 `final_submission_preview.docx`，不计入正式完成态

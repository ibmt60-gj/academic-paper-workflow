# 交互式学术论文写作工作流

这个工作流用于把“论文大纲”逐步推进为“可提交稿”。

## 启动入口

执行本工作流时，助手只需要先阅读本文件。

本文件是工作流总入口，会说明阶段顺序、目录结构、执行规则和必要脚本。进入具体阶段时，助手应按需读取对应辅助文件：

- 进入启动阶段前，按需读取 [PHASE_0_INIT_WORKSPACE.md](/Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow/PHASE_0_INIT_WORKSPACE.md)
- 需要理解模板结构时，按需读取 [templates/README.md](/Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow/templates/README.md)
- 需要理解论文任务归档规则时，按需读取 [paper_runs/README.md](/Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow/paper_runs/README.md)
- 需要理解本仓库的 Git / GitHub 日常使用方式时，按需读取 [GIT_USAGE.md](/Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow/GIT_USAGE.md)

新开 Codex 对话执行本工作流时，可以使用以下最小启动提示：

```text
我要执行本地交互式学术论文写作工作流。

工作流目录是：
/Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow

请先阅读 README.md，并按其中的阶段提醒制执行。
```

## 核心改进

### 1. 每篇论文单独归档

从现在开始，每次执行新的论文写作任务，都应在 `paper_runs/` 下新建一个以论文题目规范化命名的独立文件夹。

推荐结构：

- `academic_paper_workflow/paper_runs/<论文题目规范化>/`

例如：

- `academic_paper_workflow/paper_runs/从预案检索到逻辑生成_应急决策的张量积机理及其组织含义/`

这样做的目的：

- 保留每一次论文写作任务的全部过程产物
- 避免新任务覆盖旧任务
- 便于回溯每一步的修改历史和版本

初始化方式：

- 推荐运行：`bash ./init_paper_workspace.sh "论文题目"`
- 如需在用户确认“输入已准备好”后自动连续执行资料理解阶段与 Step 1 到 Step 8，可运行：`bash ./init_paper_workspace.sh --mode auto "论文题目"`
- 初始化后会自动生成：
  - `outline.md`
  - `writing_requirements.md`
  - `progress.md`
- `RUN_INFO.md` 中会记录“输入完成后执行模式”，可选值为 `逐步确认` 或 `自动执行`
- 初始化采用临时目录生成机制，全部文件生成成功后才会创建正式论文目录

模板说明：

- 空白模板统一放在 `templates/` 下
- 其中 `templates/input/` 保存输入模板
- `templates/materials/` 保存资料目录、资料索引和资料理解模板
- `templates/steps/` 保存 Step 1 到 Step 8 的空白产出模板
- workflow 调试、脚本验收和临时验证产生的测试任务目录，不得放在 `paper_runs/` 下，应统一放入 `archive/test_runs/`
- 历史迁移产出保存在 `archive/legacy_step_outputs/`，不得作为新论文模板使用
- 实际论文写作只能在 `paper_runs/<论文题目>/` 下进行

### 2. 每篇论文预置资料目录

每个论文文件夹下都必须预置一个 `00_source_materials/` 目录，用于存放该论文的重要参考文献和资料。

固定结构：

- `00_source_materials/references/`
- `00_source_materials/notes/`
- `00_source_materials/cases/`
- `00_source_materials/data/`
- `00_source_materials/images/`

辅助输入文件：

- `00_source_materials/reference_leads.md`

使用规则：

- 在整个工作流执行过程中，应优先参考 `00_source_materials/` 中的材料
- 用户新补充的文献、笔记、案例、数据和图片，都应放入这个目录
- 如果用户只有引文信息、DOI、网页链接、数据库链接或书目信息，也可写入 `00_source_materials/reference_leads.md`
- 若用户提供的材料与外部检索结果不一致，应优先显式比对并说明差异，不能直接忽略用户材料
- 用户不需要指定资料应该用于哪个章节或哪个步骤
- 助手负责理解资料内容，并判断其与论文撰写之间的支撑关系
- 对 `reference_leads.md` 中的线索，助手应主动检索文献、补充元数据，并将结果写入 `source_index.md`
- 每一步产出都必须包含“本步骤资料使用记录”
- 如果某份资料暂时没有被使用，助手必须说明原因，而不是默认忽略

资料理解索引：

- 每篇论文的 `00_source_materials/` 下会自动生成 `source_index.md`
- `source_index.md` 由助手维护，不要求用户填写
- 它用于记录资料内容、文献线索检索结果、可能支撑的论点、已使用位置和暂未使用原因
- 总模板见 [source_index.md](/Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow/templates/materials/source_index.md)

## 正确执行方式

这个工作流必须从“启动阶段（Phase 0）”开始，正式写作从 `Step 1` 开始。

## 阶段提醒制

整个工作流采用“阶段提醒制”。在进入每一个阶段前，助手必须先提醒用户：

- 当前阶段目标
- 用户现在需要做什么
- 助手接下来会做什么
- 是否需要用户确认后再继续

不得在没有提醒的情况下直接跨阶段执行。

### 阶段 0：启动阶段

触发条件：

- 用户给出论文题目

阶段目标：

- 确认论文题目
- 创建该论文的独立工作区

用户需要做：

1. 确认论文题目是否为最终版
2. 是否允许助手创建论文工作区
3. 选择输入完成后执行模式：`逐步确认` 或 `自动执行`

用户此阶段不需要做：

- 不需要放资料
- 不需要填写大纲
- 不需要指定文献用途

助手需要做：

1. 提醒用户即将初始化独立论文工作区
2. 执行启动初始化动作
3. 确认输入完成后执行模式是 `逐步确认` 还是 `自动执行`
4. 创建完成后，告知用户论文目录、资料目录、`outline.md`、`writing_requirements.md`、`RUN_INFO.md` 和 `progress.md` 的位置
5. 然后进入“输入准备阶段”的提醒，而不是直接进入 Step 1

启动阶段标准提醒：

```text
现在进入启动阶段。
你现在只需要确认三件事：
1. 论文题目是否为最终版
2. 是否允许我创建该论文的独立工作区
3. 输入完成后采用“逐步确认”还是“自动执行”

我创建完成后，会告诉你资料目录、大纲输入文件、写作要求文件、任务信息文件和进度文件的位置。
放资料和填写大纲属于后续阶段，现在还不需要做。
```

### 阶段 1：输入准备阶段

触发条件：

- 启动阶段已完成
- 论文工作区已创建

阶段目标：

- 让用户完成正式写作前的输入准备
- 包括资料、大纲和写作要求

用户需要做：

1. 将论文相关资料放入 `00_source_materials/`
2. 如只有引文信息或链接线索，可填写 `00_source_materials/reference_leads.md`
3. 填写 `outline.md`
4. 填写 `writing_requirements.md`
5. 完成后告诉助手“输入已准备好”
6. 如果暂时没有资料，告诉助手“暂无资料，大纲和要求已准备好”

资料放置建议：

- `references/`：论文、书籍、报告、政策文件、PDF
- `notes/`：读书笔记、摘录、你的想法
- `cases/`：案例材料、新闻、事件时间线
- `data/`：表格、统计数据
- `images/`：图表、截图、示意图
- `reference_leads.md`：标准引文、DOI、URL、数据库条目、网页链接、课程书单线索

用户此阶段不需要做：

- 不需要指定资料用于哪个章节
- 不需要指定资料用于哪个步骤
- 不需要整理成引用格式
- 不需要先把只有线索的文献手动下载成 PDF；可先写入 `reference_leads.md`

输入准备阶段只接受文件内输入，不接受用户在对话中直接给出大纲或写作要求正文。

助手需要做：

1. 告知用户资料目录、`reference_leads.md`、`outline.md` 和 `writing_requirements.md` 的位置
2. 明确说明用户只需提供输入，不需要分配资料用途
3. 若用户提供的是引文或链接线索，助手后续需主动检索而不是要求用户先补全文
4. 等待用户确认“输入已准备好”或“暂无资料，大纲和要求已准备好”
5. 在进入下一阶段前，检查 `00_source_materials/`、`reference_leads.md`、`outline.md` 和 `writing_requirements.md`

输入准备阶段标准提醒：

```text
现在进入输入准备阶段。
请完成以下输入：
1. 把论文相关资料放入 00_source_materials/
2. 如只有引文信息或链接线索，填写 00_source_materials/reference_leads.md
3. 填写 outline.md
4. 填写 writing_requirements.md

你只需要放资料，不需要告诉我每份资料用于哪一章或哪一步。
如果你手头只有文献引用信息、DOI 或链接，也可以直接写入 reference_leads.md，后续由我负责检索。
后续我会负责理解资料，并判断它们如何支撑论文写作。

本阶段只接受写入文件后的输入，不接受在对话中直接提交大纲或写作要求正文。

完成后，请回复“输入已准备好”。
如果暂时没有资料，请回复“暂无资料，大纲和要求已准备好”。
```

### 阶段 2：资料理解阶段

触发条件：

- 用户已确认输入已准备好，或说明暂无资料但大纲和要求已准备好

阶段目标：

- 理解资料、大纲和写作要求之间的关系
- 生成或更新 `source_index.md`
- 生成资料理解阶段独立产出文件
- 按执行模式决定本阶段是否暂停等待确认

助手需要做：

1. 读取 `outline.md`
2. 读取 `writing_requirements.md`
3. 检查 `00_source_materials/`
4. 检查 `00_source_materials/reference_leads.md`
5. 如存在文献线索，则主动检索可获得的文献或可靠元数据
6. 理解资料与论文大纲、写作要求之间的支撑关系
7. 生成或更新 `source_index.md`
8. 生成 `00_source_materials/materials_understanding/materials_understanding.md`
9. 读取 `RUN_INFO.md` 中的“输入完成后执行模式”
10. 若执行模式为 `逐步确认`，则等待用户确认资料理解是否正确后再继续
11. 若执行模式为 `自动执行`，则默认直接继续；但遇到重大歧义、关键资料缺口或会显著改变论文方向的分歧时，应暂停一次请求确认
12. 之后进入正式写作阶段

资料理解阶段标准提醒：

```text
现在进入资料理解阶段。
我会读取 outline.md、writing_requirements.md、00_source_materials/ 和 reference_leads.md。

你不需要指定资料用途。
我会负责判断资料如何支撑论文题目、大纲和写作要求，并在有文献线索时主动检索，再生成 source_index.md。
如果当前执行模式是“逐步确认”，我会在本阶段结束后等待你确认。
如果当前执行模式是“自动执行”，我会默认继续往下推进；只有遇到重大歧义时才会暂停确认。
```

### 阶段 3：正式写作阶段

触发条件：

- 用户已经提供论文大纲
- 写作要求已明确，或用户确认暂无额外要求
- 资料理解阶段已完成；若执行模式为 `逐步确认`，则还需获得用户确认

阶段目标：

- 按 Step 1 到 Step 8 逐步生成论文产出物

助手需要做：

1. 在进入 Step 1 前读取 `RUN_INFO.md` 中的“输入完成后执行模式”
2. 在每一步开始前提醒用户当前步骤目标和用户需要重点确认的内容
3. 每一步开始前检查 `00_source_materials/`
4. 每一步开始前按需更新 `source_index.md`
5. Step 1 需额外形成论文贡献陈述 `contribution_statement.md`
6. Step 2 需额外形成文献立场矩阵 `literature_position_matrix.md`
7. Step 3 需额外形成主张-证据-推论卡片 `claim_evidence_inference_cards.md`
8. Step 8 需额外形成终稿质量评分表 `quality_review.md`
9. Step 2 到 Step 8 必须显式记录“本步骤质量增强文件使用记录”，说明如何继承前置质量文件
10. 每一步产出中填写“本步骤资料使用记录”
11. 每一步产出中填写“本步骤写作要求使用记录”
12. 每一步完成后更新 `progress.md`
13. 如果执行模式为 `逐步确认`，则每一步完成后暂停，等待用户确认
14. 如果执行模式为 `自动执行`，则 Step 1 到 Step 8 连续执行，中间不等待用户确认，生成终稿后再统一汇报；但如出现重大歧义、关键资料缺口或会显著改变论文方向的分歧，仍应暂停一次请求确认
15. 如果 Step 8 终稿已获用户最终确认，应将 `progress.md` 更新为 `Step 8 已确认，工作流完成`

正式写作阶段标准提醒：

```text
现在进入正式写作阶段。
接下来我会严格按 Step 1 到 Step 8 执行。

每一步我都会检查资料目录、记录资料使用情况、输出当前步骤产出物，并等待你确认后再继续。
如果你确认，我将从 Step 1 开始。
```

如果 `RUN_INFO.md` 中的输入完成后执行模式是 `自动执行`，则从资料理解阶段开始默认不中途暂停，直接连续推进到 Step 8；只有遇到重大歧义时才暂停确认。

### 启动阶段的初始化动作

触发时机：

- 只要用户给出论文题目，就应立即执行
- 即使用户暂时还没提供大纲，也应先创建目录

启动阶段的初始化任务：

1. 在 `paper_runs/` 下创建以论文题目规范化命名的独立文件夹
2. 在该文件夹下预置 `00_source_materials/`
3. 在 `00_source_materials/` 下预置：
   - `references/`
   - `notes/`
   - `cases/`
   - `data/`
   - `images/`
4. 同时生成 `00_source_materials/reference_leads.md`
5. 告知用户：现在可以把论文相关 PDF、笔记、案例和数据放进去，也可以把引文信息和链接线索写入 `reference_leads.md`
6. 之后进入输入准备阶段，而不是直接进入 Step 1

启动阶段初始化的意义：

- 用户可以在正式写作前先把材料放进去
- 助手在资料理解阶段和后续每一步中都能优先读取这些材料
- 避免“目录还没建好，材料无处可放”的问题

推荐执行命令：

```bash
cd /Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow
bash ./init_paper_workspace.sh [--mode confirm|auto] "你的论文题目"
```

大纲填写模板：

- [outline.md](/Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow/templates/input/outline.md)
- 每次初始化新论文工作区后，会自动复制一份到该论文目录下，文件名为 `outline.md`

### 启动阶段之后

1. 进入输入准备阶段：用户放入资料，并填写 `outline.md` 与 `writing_requirements.md`
2. 若用户只有引文信息或链接，可填写 `00_source_materials/reference_leads.md`
3. 用户确认“输入已准备好”后，按 `RUN_INFO.md` 中的执行模式进入资料理解阶段
4. 若为 `逐步确认`，则资料理解阶段完成后等待确认，再进入正式写作阶段
5. 若为 `自动执行`，则资料理解阶段与 Step 1 到 Step 8 默认连续推进；但遇到重大歧义、关键资料缺口或会显著改变论文方向的分歧时，仍应暂停一次确认
6. 正式写作阶段从 Step 1 开始继续推进
7. 用户最终确认 Step 8 终稿后，应将进度更新为 `Step 8 已确认，工作流完成`
8. 最终产出为该论文目录下 `08_final_submission/final_submission.docx`

## 单篇论文目录模板

- `00_source_materials/`
- `RUN_INFO.md`
- `00_source_materials/reference_leads.md`
- `00_source_materials/source_index.md`
- `00_source_materials/materials_understanding/materials_understanding.md`
- `outline.md`
- `writing_requirements.md`
- `progress.md`
- `01_outline_normalization/normalized_outline.md`
- `01_outline_normalization/contribution_statement.md`
- `02_section_goals/section_goals.md`
- `02_section_goals/literature_position_matrix.md`
- `03_evidence_sources/evidence_sources.md`
- `03_evidence_sources/claim_evidence_inference_cards.md`
- `04_paragraph_skeleton/paragraph_skeleton.md`
- `05_draft/draft.md`
- `06_structural_revision/structural_revision.md`
- `07_references_integration/references_integration.md`
- `08_final_submission/step8_record.md`
- `08_final_submission/final_submission.md`
- `08_final_submission/quality_review.md`
- `08_final_submission/final_submission.docx`

## 标准执行顺序

0. 启动阶段：初始化论文工作区
1. 输入准备阶段：放入资料，填写大纲与写作要求
2. 资料理解阶段：生成 `source_index.md` 和 `materials_understanding.md`
3. Step 1：明确大纲层级，并形成论文贡献陈述
4. Step 2：为每一节定义写作目标，并形成文献立场矩阵
5. Step 3：确认每一节的证据和参考来源，并形成主张-证据-推论卡片
6. Step 4：搭建段落骨架
7. Step 5：撰写内容粗稿
8. Step 6：做结构性修订
9. Step 7：补充文献与引证
10. Step 8：做语言与格式润色，形成 Word 版可提交稿，并完成质量评分复核

## 执行规则

- 不跳步。
- 不得跳过启动阶段（Phase 0）。
- 用户确认“输入已准备好”后，后续资料理解阶段与正式写作阶段的推进方式以 `RUN_INFO.md` 中的“输入完成后执行模式”为准。
- 若执行模式为 `逐步确认`，则资料理解阶段和每步写作完成后都暂停，等待用户确认。
- 若执行模式为 `自动执行`，则资料理解阶段与 Step 1 到 Step 8 默认不中途暂停，连续执行到生成终稿。
- 即使在 `自动执行` 模式下，如遇到重大歧义、关键资料缺口或会显著改变论文方向的分歧，也应暂停一次请求确认。
- 每步完成、确认或回退后，都应使用 `update_progress.sh` 更新 `progress.md`。
- Step 8 终稿如已获用户最终确认，应统一更新为 `Step 8 已确认，工作流完成`。
- Step 8 的流程记录、资料使用记录和质量继承记录应写入 `08_final_submission/step8_record.md`，不得写入 `final_submission.md`。
- Step 8 的默认导出视为正式导出；正式导出前必须完成 `quality_review.md`。
- 只有在用户明确要求“先看一版 Word”时，才允许额外导出预览稿 `final_submission_preview.docx`。
- 预览导出不计入正式完成态，不得据此更新为 `Step 8 已完成` 或 `Step 8 已确认，工作流完成`。
- 如用户要求修改，则在当前步或回退步骤中修改后再继续。
- 每一步都应保留该步独立产出物，便于追踪和回溯。
- 每次新论文任务都必须新建独立文件夹，不能覆盖旧任务。
- 每一步写作前，都应先查看 `00_source_materials/` 中是否已有相关资料。
- 如 `reference_leads.md` 中存在文献线索，应优先尝试主动检索，而不是要求用户先补全文文件。
- 每一步写作前，都应检查并按需更新 `00_source_materials/source_index.md`。
- 每一步产出文件中，都应填写“本步骤资料使用记录”。
- 每一步产出文件中，都应填写“本步骤写作要求使用记录”。
- Step 2 到 Step 8 的主文件中，都应填写“本步骤质量增强文件使用记录”。
- Step 2 到 Step 8 的“本步骤质量增强文件使用记录”中，至少前三项不得留空：`本步骤实际读取的质量文件`、`本步骤如何继承前置质量约束`、`本步骤新增了哪些质量澄清或修正`。
- Step 1 必须明确研究问题、研究缺口和核心贡献。
- Step 2 的文献综述应围绕立场、争论和局限组织，而不是只堆列文献。
- Step 3 必须把关键章节写成“主张-证据-推论”卡片，确保推理链闭合。
- Step 4 到 Step 7 必须继续继承并落实前面形成的贡献陈述、文献立场矩阵和主张-证据-推论卡片。
- Step 8 必须完成质量评分表，检查研究问题、理论贡献、论证严密性与摘要-引言-结论闭环。

## Word 终稿导出

Step 8 的最终交付物是 Word 文件：

- `08_final_submission/final_submission.docx`

同时保留 Markdown 文件：

- `08_final_submission/final_submission.md`：只保留可提交正文
- `08_final_submission/step8_record.md`：保留 Step 8 执行记录
- `08_final_submission/quality_review.md`：正式导出前必须完成

默认导出命令（正式导出）：

```bash
cd /Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow
bash ./export_final_docx.sh "paper_runs/论文目录名"
```

只有当用户明确要求预览稿时，才使用：

```bash
cd /Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow
bash ./export_final_docx.sh --preview "paper_runs/论文目录名"
```

注意：

- 优先使用 Pandoc 导出 Word 文件
- 如果未安装 Pandoc，则使用本工作流内置的 `python-docx` 备用导出器
- 备用导出器适合基础论文结构，复杂表格、脚注、交叉引用和定制样式仍建议使用 Pandoc
- 正式导出前，`quality_review.md` 必须已脱离模板状态
- 正式导出前，`quality_review.md` 中 `是否已经达到可提交状态` 必须明确写成肯定结论，例如：`是` / `已达到可提交状态`
- 预览导出会生成 `08_final_submission/final_submission_preview.docx`
- 预览导出不等于正式完成稿

## 进度更新

推荐命令：

```bash
cd /Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow
bash ./update_progress.sh "paper_runs/论文目录名" "Step 1" "Step 1 已完成，待用户确认" "请确认标准化大纲"
```

终稿最终确认后的推荐命令：

```bash
bash ./update_progress.sh "paper_runs/论文目录名" "Step 8" "Step 8 已确认，工作流完成" "本轮工作流已完成"
```

阶段进度也可以更新：

```bash
bash ./update_progress.sh "paper_runs/论文目录名" "Phase 2" "资料理解阶段已完成，待用户确认" "请确认资料理解是否正确"
```

合法阶段/步骤标记：

- `Phase 0` 到 `Phase 3`
- `Step 1` 到 `Step 8`

如果传入其他标记，进度脚本会直接报错，不会写入 `progress.md`。

推荐终态写法：

- `Step 8 已完成，待用户确认`：终稿已生成，等待用户最终确认
- `Step 8 已确认，工作流完成`：用户已确认终稿，本轮工作流正式结束

## 目录完整性校验

推荐命令：

```bash
cd /Users/jingmac/workspce_creator/NSF_writesup/writing/academic_paper_workflow
bash ./validate_workflow.sh "paper_runs/论文目录名"
```

严格门禁校验：

```bash
bash ./validate_workflow.sh --strict "paper_runs/论文目录名"
```

普通校验会把未填写内容作为警告；严格门禁会把这些警告视为失败，适合在进入资料理解阶段、正式写作阶段或最终导出前使用。

工作流收口建议：

1. 完成 `final_submission.md`
2. 完成 `step8_record.md`
3. 完成 `quality_review.md`
4. 运行正式导出，生成 `final_submission.docx`
5. 运行 `bash ./validate_workflow.sh --strict "paper_runs/论文目录名"`
6. 再将状态更新为 `Step 8 已完成，待用户确认` 或 `Step 8 已确认，工作流完成`

校验内容包括：

- 必要文件和目录是否存在
- `reference_leads.md` 若存在，是否可作为文献线索输入使用
- `RUN_INFO.md` 中的输入完成后执行模式是否已明确填写且取值合法
- `outline.md`（或旧任务中的 `outline_input.md`）是否已经包含真实论文题目和大纲条目
- `source_index.md` 和 `materials_understanding.md` 是否仍未生成
- Step 1、Step 2、Step 3、Step 8 的质量增强辅助文件是否存在
- 每个已执行的 Step 文件是否仍停留在 `状态：待开始` 模板状态
- 每个 Step 文件是否包含资料使用记录和写作要求使用记录
- Step 2 到 Step 8 是否包含“本步骤质量增强文件使用记录”，以及前三个关键字段是否已填写
- `final_submission.md` 是否仍混入流程记录或状态信息
- `quality_review.md` 是否明确给出“已达到可提交状态”的肯定结论
- 当 `quality_review.md` 已明确给出“已达到可提交状态”的肯定结论时，Step 8 的 `final_submission.docx` 是否已经生成

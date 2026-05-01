# Git / GitHub 日常使用说明

这份说明是给当前这个 workflow 仓库用的。

## 一句话理解

- 本地目录：你真正修改文件的地方
- Git：记录每次修改
- GitHub：远程备份和版本历史

你以后**仍然是直接在本地修改 workflow 文件**，不需要先去 GitHub 网站上改。

## 推荐协作方式

对你来说，最省心的方式是：

1. 直接告诉助手你想怎么改 workflow
2. 助手修改本地文件
3. 你决定这次是否要做版本记录
4. 如需版本记录，再让助手执行 Git 提交和推送

也就是说，你通常不需要自己手动敲 Git 命令。

## 你可以直接怎么说

常用说法：

- “把这个 workflow 改成……”
- “改完后帮我提交版本”
- “这次先不要 push”
- “改完后直接 push 到 GitHub”

## 如果你希望助手一起做版本管理

你可以直接说：

- “修改完成后帮我提交 commit”
- “修改完成后帮我 push 到 GitHub”

助手会继续帮你执行：

```bash
git status
git add .
git commit -m "..."
git push
```

## 如果你想自己执行

最常用的 4 条命令如下：

```bash
git status
git add .
git commit -m "写一句说明这次改了什么"
git push
```

含义：

- `git status`：查看哪些文件变了
- `git add .`：把当前修改加入暂存区
- `git commit -m "..."`：生成一个版本记录
- `git push`：把本地版本同步到 GitHub

## 这个仓库当前的版本管理边界

纳入 Git 管理：

- 脚本
- README 和规则文档
- 模板文件

不纳入 Git 管理：

- `paper_runs/` 里的真实论文任务
- `archive/test_runs/`
- `archive/legacy_step_outputs/`
- `.docx`
- `.DS_Store`

这些规则由 `.gitignore` 控制。

## 一个最常见的实际流程

例如你以后说：

> 把 Step 8 的说明改一下，改完后帮我提交并 push

助手会做两件事：

1. 改本地文件
2. 帮你完成 Git 提交和 GitHub 同步

## 什么时候不需要 commit / push

如果你只是临时试改、还没想好，或者还在讨论设计，可以先不提交版本。

适合先不提交的情况：

- 还在讨论 workflow 应该怎么改
- 只是做一次临时测试
- 还没确认这次修改是否保留

## 什么时候建议 commit / push

建议做版本记录的情况：

- 某条 workflow 规则已经定稿
- 脚本逻辑已经改完并验证通过
- 模板结构已经稳定
- 你希望把当前状态作为一个可回退版本保存下来

## 当前仓库信息

- 本地仓库已初始化
- 默认分支：`main`
- 已连接 GitHub 远程仓库：
  - `https://github.com/ibmt60-gj/academic-paper-workflow.git`

## 最后一句

你不需要先学会整套 Git，再来维护这个 workflow。

最实用的做法就是：

- 你负责说“要改什么”
- 助手负责“改文件 + 需要时做版本管理”

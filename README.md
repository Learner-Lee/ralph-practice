# Ralph Loop 学习实践仓库

本仓库记录了一次完整的 Ralph Loop 上手学习过程，包含学习文档、完整对话记录和三个模块的动手实践代码。

> **Ralph Loop** 是 Geoffrey Huntley 提出的 AI 编码循环工作流模式：用 Shell 循环反复把任务描述喂给 Claude Code CLI，让 AI 自动迭代完成任务。它不是 Claude Code 的内置功能，而是一种外层脚本组合用法。

---

## 仓库结构

```
.
├── README.md                          # 本文件
├── learn-ralph.md                     # 原始学习任务书（TRACE 格式）
├── ralph-loop-learning.md             # 系统学习文档（基础 / 进阶 / Master 三层模块）
├── ralph-loop-full-conversation.md    # 完整学习对话记录
└── ralph-practice/
    ├── PROMPT.md                      # 模块1：任务描述文件
    ├── AGENTS.md                      # 模块1：项目说明文件
    ├── loop.sh                        # 模块1：最简循环脚本
    ├── progress.md                    # 模块1：AI 自动维护的进度文件
    ├── output/
    │   ├── counter.py                 # 模块1 产出：Python 计数器 CLI
    │   └── counter_data.json          # 计数器数据
    └── module2/
        ├── PROMPT_plan.md             # 模块2/3：规划模式指令
        ├── PROMPT_build.md            # 模块2/3：执行模式指令
        ├── AGENTS.md                  # 模块2/3：项目说明文件
        ├── loop.sh                    # 模块3：生产级循环脚本（带计时/颜色/--push）
        ├── IMPLEMENTATION_PLAN.md     # 模块2/3：AI 生成并维护的任务清单
        ├── specs/                     # 需求文档（每个文件一个功能话题）
        │   ├── note-add.md
        │   ├── note-list.md
        │   ├── note-delete.md
        │   └── note-search.md
        └── src/
            ├── notes.py               # 模块2/3 产出：Python 笔记 CLI
            └── notes.json             # 笔记数据
```

---

## 学习路线

### 模块 1：最简循环

**核心原理：** `while` 循环 + `cat PROMPT.md | claude -p`

**产出：** `ralph-practice/output/counter.py`（支持 add / total / reset / history）

**关键文件：**
- `PROMPT.md` — 任务描述，AI 每轮读取，可热更新
- `AGENTS.md` — 项目说明（构建命令、约定）
- `loop.sh` — 带最大轮数和完成检测的循环脚本

```bash
cd ralph-practice
bash loop.sh 5      # 最多跑 5 轮
```

---

### 模块 2：双模式循环（PLANNING + BUILDING）

**核心原理：** 规划和执行分离，先生成任务清单，再逐轮消耗

**产出：** `ralph-practice/module2/src/notes.py`（支持 add / list / delete / search）

**运行流程：**
```bash
cd ralph-practice/module2

# 第一阶段：规划（1 轮，生成 IMPLEMENTATION_PLAN.md）
bash loop.sh plan 1

# 检查计划是否合理，必要时手动修正

# 第二阶段：执行（每轮做一个任务，自动 commit）
bash loop.sh build 10
```

**specs 写法原则：**
- 每个文件只描述一个功能话题
- 只写 WHAT（要实现什么），不写 HOW（怎么实现）

---

### 模块 3：生产级技巧

**生产版 loop.sh 新增能力：**

| 能力 | 用法 |
|------|------|
| 每轮计时 | 自动输出 `第N轮耗时：Xs` |
| 颜色输出 | INFO（绿）/ WARN（黄）/ ERROR（红）|
| 自动 git push | `bash loop.sh build 10 --push` |
| 前置检查 | 找不到 PROMPT 文件或 claude 命令立即报错 |

**救场三板斧：**

```bash
# 招式一：急停
Ctrl+C

# 招式二：重生成计划（需求变了或计划混乱）
rm IMPLEMENTATION_PLAN.md
bash loop.sh plan 1

# 招式三：回滚代码
git log --oneline -10
git reset --hard <commit-hash>
```

---

## 快速上手

复制 `ralph-practice/module2/` 的文件结构到你的项目：

```bash
# 1. 准备目录
mkdir my-project && cd my-project && git init

# 2. 复制模板文件
cp /path/to/this-repo/ralph-practice/module2/loop.sh .
cp /path/to/this-repo/ralph-practice/module2/PROMPT_plan.md .
cp /path/to/this-repo/ralph-practice/module2/PROMPT_build.md .

# 3. 按你的项目修改 AGENTS.md 和 specs/

# 4. 启动
bash loop.sh plan 1     # 先规划
bash loop.sh build 10   # 再执行
```

---

## 注意事项

- **root 用户下** 无法使用 `--dangerously-skip-permissions`，改用 `--allowedTools "Bash Edit Write Read Glob Grep"`
- **前 3 轮必须盯着看**，确认 AI 方向正确后再离开
- **不适合遗留代码库**、无验证标准的任务、一次性小任务
- 设置 `MAX_ITERATIONS` 防止 token 失控

---

## 参考资料

- [everything is a ralph loop — ghuntley.com](https://ghuntley.com/loop/)
- [Ralph Wiggum as a "software engineer" — ghuntley.com](https://ghuntley.com/ralph/)
- [The Ralph Playbook — claytonfarr.github.io](https://claytonfarr.github.io/ralph-playbook/)

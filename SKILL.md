---
name: doc-to-board
version: 0.1.0
description: >
  飞书文档结构解析与画板生成技能。支持：
  1) 单/多飞书文档结构解析（大纲、重点、难点、逻辑关系）
  2) 多文档间结构关联分析
  3) 基于解析结果生成飞书画板（集成 beautiful-feishu-whiteboard 风格）
  4) 交互式选择画板插入位置（单文档/多文档/新文档）
  
  触发词：doc-to-board、文档画板、文档结构图、文档大纲图、多文档关联图、
  文档结构解析、文档可视化、把文档变成画板。
---

# doc-to-board

将飞书文档解析为结构化大纲，生成精美飞书画板，并支持多文档关联分析。

## 依赖

- **Node.js ≥ 20**
- **lark-cli**（`npm install -g @larksuite/cli`）— 已认证
- **@larksuite/whiteboard-cli**（通过 npx 自动下载）

## 核心流程

```
用户输入飞书链接 → 文档获取 → 结构解析 → 画板生成 → 交互插入
```

### 流程详解

#### Step 1: 文档获取
- 支持飞书链接格式：`/docx/`、`/doc/`、`/wiki/`、`/sheets/`
- Wiki 链接自动解析为实际文档 token
- 使用 `lark-cli docs +fetch --as user --doc <URL>` 获取文档内容

#### Step 2: 结构解析
- LLM 分析文档 Block 结构，提取：
  - **大纲层级**：标题 H1-H6 的层级关系
  - **内容要点**：每个章节的关键论点/信息
  - **逻辑关系**：章节间的因果/并列/递进/对比关系
  - **重点/难点**：核心论点和复杂概念标记
- 单文档支持"解析全部"或"只解析指定章节"
- 多文档额外分析跨文档关联（引用/对应/冲突/互补）

#### Step 3: 画板生成
- 生成 SVG 前，**必须先读取 `lib/whiteboard-rules/RULES.md`**（SVG 画板硬规则，不可违反）
- 选择配色风格时，读取 `lib/whiteboard-rules/CATALOG.md` 和对应 `lib/whiteboard-rules/templates/<slug>/design.md`
- 从解析结果生成 SVG 画板：
  - 单文档：层级结构图 / 思维导图 / 大纲图
  - 多文档：跨文档关系图 / 对比矩阵
- 渲染流程：SVG → `whiteboard-cli` 渲染检查 → 修复循环
- 支持用户选择配色风格（CATALOG.md 中的 35 种）

**多文档画板布局硬规则（必须遵守）：**

1. **动态画布高度**：不写死 SVG `height`，根据所有内容区域的底部边界 + 30px padding 计算。禁止画布底部出现大面积空白。
2. **跨文档关联线坐标避让**：
   - 关联线在穿过文档列间隙时，必须**垂直间距 ≥ 30px**
   - 多条线穿过同一间隙时，按 Y 坐标排序，依次分布在不同高度
   - 关联线的起止点必须是**目标节点的上下边缘中点**，不能估算
   - 禁止多条线交汇或重叠于同一点
3. **文档区域高度**：每个文档列的背景矩形高度 = 该列最后一个内容节点的 bottom + 20px padding。各列高度可以不同。
4. **链接标识**：在每个文档列的标题栏（深色区域），用一行灰色小字写**文档标题的缩写标识**（如 "J1pWdBJB..."）。完整链接只在 agent 回复消息中给出，不写在画板上。

#### Step 4: 交互选择插入位置

在画板 SVG 生成并通过 `--check` 验证（0 errors）后，**不要立即创建画板**，而是通过交互卡片让用户选择插入目标：

**场景 A：单文档**
用户只给了一个飞书链接，询问将画板插入该文档的哪个位置：

```
feishu_ask_user_question({
  questions: [{
    header: "插入位置",
    question: "画板已生成，希望插入到文档的什么位置？",
    options: [
      { label: "文档开头", description: "作为文档第一块内容" },
      { label: "文档末尾", description: "追加到文档最后" },
      { label: "指定章节后", description: "需要你告诉我是哪个章节" },
      { label: "新建文档", description: "创建一个新文档放置画板" }
    ],
    multiSelect: false
  }]
})
```

如果用户选择"指定章节后"，需要进一步询问具体是哪个章节（基于解析出的 H1 标题列表给出选项）。

**场景 B：多文档**
用户给了多个飞书链接，先让用户选择目标文档，再选择插入位置：

```
feishu_ask_user_question({
  questions: [
    {
      header: "目标文档",
      question: "画板已生成，希望插入到哪个文档？",
      options: [
        { label: "文档A标题", description: "linkA" },
        { label: "文档B标题", description: "linkB" },
        { label: "新建文档", description: "创建一个新文档放置画板" }
      ],
      multiSelect: false
    },
    {
      header: "插入位置",
      question: "希望插入到文档的什么位置？",
      options: [
        { label: "文档开头", description: "作为文档第一块内容" },
        { label: "文档末尾", description: "追加到文档最后" },
        { label: "指定章节后", description: "需要你告诉我是哪个章节" }
      ],
      multiSelect: false
    }
  ]
})
```

**插入执行：**
用户选择后，按选择执行插入：
- **文档开头**：`docs +update --mode prepend --markdown '<whiteboard ...>'`
- **文档末尾**：`docs +update --mode append --markdown '<whiteboard ...>'`
- **指定章节后**：`docs +update --mode insert_after --markdown '<whiteboard ...>'`
- **新建文档**：`docs +create --content '<title>...</title><whiteboard ...>'`

拿到 board_token 后，执行 SVG → whiteboard-cli 上传流程。

#### Step 5: 交付
- 给用户飞书文档链接（画板所在文档）
- 附带画板渲染截图（通过 `whiteboard +query --output_as image` 获取）
- **附带所有源文档的完整链接清单**（按画板中出现的顺序排列）
  - 每条包含：文档标题 + 完整飞书链接
  - 多文档时标注关联关系和对应章节
- 告知用户可切换配色风格

## 文件结构

```
doc-to-board/
├── SKILL.md                        # 本文件
├── README.md                       # 项目说明
├── scripts/
│   └── preflight.sh                # 依赖检查
├── lib/
│   ├── parse_structure.md          # 文档结构解析指令
│   ├── analyze_multi_doc.md       # 多文档关联分析指令
│   ├── generate_svg.md             # SVG 画板生成指令
│   ├── board_templates.md          # 画板模板说明
│   └── whiteboard-rules/           # 飞书 SVG 画板规则与配色
│       ├── RULES.md               # SVG 画板硬规则（必须遵守）
│       ├── CATALOG.md             # 35 种配色风格目录
│       ├── templates/             # 各风格配色定义
│       └── assets/                # 风格预览图
└── output/                         # 渲染输出（gitignored）
```

## LLM 工作指南

### 获取文档
```bash
# 普通文档
lark-cli docs +fetch --as user --doc "URL_OR_TOKEN"

# Wiki 文档（先解析再获取）
lark-cli wiki spaces get_node --params '{"token":"wiki_token"}' --as user
# 返回 obj_type 和 obj_token 后再 fetch
```

### 创建空白画板并获取 token
```bash
lark-cli docs +update --doc "DOC_ID" --mode append \
  --markdown '<whiteboard type="blank"></whiteboard>' --as user
# 响应中 data.board_tokens[0] 即画板 token
```

### 渲染 SVG 到飞书画板
```bash
# 1. 本地渲染检查
npx -y @larksuite/whiteboard-cli@^0.2.11 \
  -i diagram.svg -o diagram.png -f svg

# 2. 语法检查
npx -y @larksuite/whiteboard-cli@^0.2.11 \
  -i diagram.svg -f svg --check

# 3. 上传到飞书画板（首次 / 空画板）
npx -y @larksuite/whiteboard-cli@^0.2.11 \
  -i diagram.svg --to openapi --format json | \
lark-cli docs +whiteboard-update \
  --whiteboard-token <TOKEN> \
  --source - --input_format raw \
  --idempotent-token <UNIQUE> --as user

# 4. 已有画板覆盖（先 dry-run 检查）
npx -y @larksuite/whiteboard-cli@^0.2.11 \
  -i diagram.svg --to openapi --format json | \
lark-cli docs +whiteboard-update \
  --whiteboard-token <TOKEN> \
  --source - --input_format raw \
  --idempotent-token <UNIQUE> --overwrite --dry-run --as user
```

### 查看画板渲染结果
```bash
lark-cli whiteboard +query \
  --whiteboard-token <TOKEN> \
  --output_as image --output ./output/ --as user
```

## 配色风格选择

默认使用 **Monochrome**（克制、专业、适合文档结构图）。
如用户有偏好，参考 `lib/whiteboard-rules/CATALOG.md` 选择。
可用的风格分类：
- **Restrained**：Monochrome、Grove、Macchiato、Reading Room 等（严肃/专业）
- **Balanced**：Coral、Lime Slab、Pin & Paper、Soft Editorial 等（通用/现代）
- **Bold**：BlockFrame、Crayon Stack、Specimen Bold 等（活泼/高冲击）

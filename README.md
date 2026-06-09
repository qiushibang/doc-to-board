# doc-to-board

飞书文档结构解析与画板生成技能。将飞书文档解析为结构化大纲，生成精美飞书画板，支持多文档关联分析。

## 功能

- **单文档解析**：获取飞书文档，分析大纲/重点/难点/逻辑关系，生成结构图
- **多文档关联**：解析多个文档，发现跨文档的结构关联（引用/对比/冲突/互补）
- **画板生成**：基于 beautiful-feishu-whiteboard 风格系统，生成精美 SVG 画板
- **交互插入**：选择画板插入到指定文档的指定位置

## 依赖

- Node.js ≥ 20
- lark-cli (`npm install -g @larksuite/cli`)
- @larksuite/whiteboard-cli (via npx)

## 快速开始

```bash
# 1. 检查依赖
bash scripts/preflight.sh

# 2. 将此目录安装为 agent skill
# 按你的 agent 框架说明操作
```

## 使用方式

向 agent 发送飞书文档链接，然后：

1. **单文档**：「把这篇文章生成结构图」→ 解析 → 生成画板 → 选择插入位置
2. **多文档**：「对比这几篇文章的结构」→ 批量解析 → 关联分析 → 生成关系图 → 选择目标文档

## 项目结构

```
doc-to-board/
├── SKILL.md                        # 技能定义与 LLM 工作指南
├── README.md                       # 本文件
├── scripts/
│   └── preflight.sh                # 依赖检查
├── lib/
│   ├── parse_structure.md          # 文档结构解析指令
│   ├── analyze_multi_doc.md       # 多文档关联分析指令
│   ├── generate_svg.md            # SVG 画板生成指令
│   └── board_templates.md          # 画板模板说明
└── beautiful-feishu-whiteboard/    # 画板渲染子模块
    ├── RULES.md                   # SVG 画板硬规则
    ├── CATALOG.md                 # 35 种配色风格
    └── templates/                 # 各风格定义
```

## License

MIT

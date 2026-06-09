# SVG 画板生成指令

> 基于 beautiful-feishu-whiteboard 的 RULES.md 规则，将文档结构解析结果转化为 SVG 画板。

## 前置步骤

1. 读取 `lib/whiteboard-rules/RULES.md` — 了解 SVG 画板的硬规则
2. 读取 `lib/whiteboard-rules/CATALOG.md` — 了解可用配色风格
3. 选择一个配色风格（默认 Monochrome），读取对应 `lib/whiteboard-rules/templates/<slug>/design.md`

## 画板布局策略

### 单文档结构图

**推荐布局：层级树形图**

```
┌─────────────────────────────────────┐
│          文档标题                     │
├─────────────────────────────────────┤
│  ┌───────┐     ┌───────┐           │
│  │ 第1章 │─────│ 第2章 │           │
│  └──┬────┘     └──┬────┘           │
│     │             │                 │
│  ┌──▼────┐     ┌──▼────┐           │
│  │ 1.1   │     │ 2.1   │           │
│  └──┬────┘     └───────┘           │
│     │                                │
│  ┌──▼────┐                          │
│  │ 1.1.1 │                          │
│  └───────┘                          │
└─────────────────────────────────────┘
```

**设计要点：**
- 顶层：文档标题（大字、主色调）
- 第 1 层：H1 章节（中等矩形、标题色）
- 第 2 层：H2 小节（较小矩形）
- 第 3 层及以下：折叠为要点列表（避免层级过深）
- 难点标记：红色边框或星标
- 关系连线：用 connector 表示章节间的逻辑关系

### 多文档关系图

**推荐布局：左右并列 + 中间关联**

```
┌──────────┐          ┌──────────┐
│  文档 A   │◄────────│  文档 B   │
│          │          │          │
│ ┌──────┐ │ reference│ ┌──────┐ │
│ │ A.1  │─┼──────────┼─│ B.1  │ │
│ └──────┘ │          │ └──────┘ │
│ ┌──────┐ │          │ ┌──────┐ │
│ │ A.2  │ │ conflict │ │ B.2  │ │
│ └──────┘─┼──────────┼─└──────┘ │
└──────────┘          └──────────┘
```

**设计要点：**
- 每个文档一个独立区域（浅色背景矩形）
- 文档内章节用层级布局
- 跨文档关联用不同颜色/虚实的线连接
- 关联类型用图例说明

## SVG 编写规则

### 文档链接标注（所有画板必须执行）

**每个文档区域必须标注来源链接，采用三层标注策略：**

1. **区域标题**：文档标题节点旁用灰色小字显示 `token 前 8 位 + ...`
2. **节点底部**：每个 H1 章节节点下用 10px 灰色字标注 `📄 doc_token...`
3. **交付消息**：agent 回复时附带完整的文档链接清单

**SVG 示例：**
```xml
<!-- 文档A 标题区域 -->
<text x="100" y="130" text-anchor="middle" font-size="17" font-weight="bold" fill="#FAFADF">Vibe Coding</text>
<text x="100" y="145" text-anchor="middle" font-size="9" fill="#8A8A80">KZlbdMZF...</text>

<!-- H1 章节节点 -->
<text x="40" y="230" font-size="14" font-weight="bold" fill="#1A1A16">Aiden 平台</text>
<text x="40" y="244" font-size="9" fill="#8A8A80">📄 KZlbdMZF...</text>
```

**多文档关联线的标注：**
- 关联线上用标签显示关系类型
- 关联线两端各标注 `doc_token...`（10px 灰色字）

### 硬规则（来自 lib/whiteboard-rules/RULES.md）
- **单字体**：不设 `font-family`，只用 size/weight/casing/letter-spacing
- **原生形状**：只用 `<rect>`（rx 圆角）、`<circle>`、`<ellipse>`、`<line>`、`<polyline>`、`<text>`
- **箭头用 marker-end**：不手绘箭头三角形
- **禁止**：gradient、filter、pattern、clipPath、mask、opacity
- **无固定画布**：逻辑坐标空间 ≈1600-1700 宽

### 文档结构图专用规则
- 每个节点包含：标题 + 摘要（2 行以内）
- 难点节点用红色边框（`stroke: #E74C3C` 或对应风格的高亮色）
- 关键概念用粗体标记
- 层级连线用灰色实线
- 逻辑关系线用彩色，附关系类型标签

### 配色使用
- 从选定风格的 design.md 获取配色定义
- **外重内轻**：外层容器深色，内层节点浅色
- 同组节点样式完全一致
- 文字保证高对比度

## 尺寸规范

| 元素 | 宽度 | 高度 | 字号 | 圆角 |
|------|------|------|------|------|
| 文档标题 | 800 | 80 | 36px bold | 8px |
| H1 章节 | 360 | fit-content | 22px bold | 6px |
| H2 小节 | 300 | fit-content | 18px | 4px |
| H3 要点 | 240 | fit-content | 16px | 4px |
| 关系标签 | fit-content | fit-content | 14px | 0 |
| 间距（垂直） | - | - | - | 40px |
| 间距（水平） | - | - | - | 60px |

## 输出

生成 SVG 文件到临时目录，然后执行渲染检查流程：

```bash
# 渲染 PNG 检查
npx -y @larksuite/whiteboard-cli@^0.2.11 -i diagram.svg -o diagram.png -f svg

# 语法检查
npx -y @larksuite/whiteboard-cli@^0.2.11 -i diagram.svg -f svg --check

# 查看并修复问题，循环直到满意
```

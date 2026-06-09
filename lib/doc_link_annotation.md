# 文档链接标注方案

> 在画板中标注文档链接，让用户可以点击跳转查看原文。

## 技术可行性分析

### 飞书画板超链接能力
经过实际验证（whiteboard-cli 输出的 OpenAPI JSON），当前画板节点**不支持超链接字段**。
node 的所有字段为：id, type, x, y, width, height, text, style, composite_shape。

### SVG `<a>` 标签测试
飞书 SVG 画板渲染时，`<a>` 标签内的 `<text>` 会被展平为普通文本节点，超链接信息丢失。

### 可行的替代方案

由于画板原生不支持超链接，采用以下三种互补方案：

---

## 方案 1：节点内标注短链接（推荐，始终使用）

在每个文档/章节节点中，用小字标注来源链接的关键标识符。

**实现方式：**
- 在章节标题旁用灰色小字显示文档名缩写或链接尾部 token
- 完整链接放在节点摘要中，便于搜索

**SVG 示例：**
```xml
<text x="100" y="50" font-size="13" font-weight="bold" fill="#1A1A16">Aiden 平台</text>
<text x="100" y="66" font-size="10" fill="#8A8A80">来源: KZlbdMZF...</text>
```

**优点：** 画板内直接可读，无需点击
**缺点：** 不能跳转，需要手动复制 token 去找文档

---

## 方案 2：画板下方文本块放完整链接清单

在画板的底部区域（或每个文档区域底部），用一个文本节点列出该文档的完整链接。

**SVG 示例：**
```xml
<!-- 文档A 区域底部 -->
<text x="40" y="580" font-size="10" fill="#5E5E54">
  📄 完整链接: https://bytedance.sg.larkoffice.com/docx/KZlbdMZF...
</text>
```

**优点：** 完整链接可直接复制到浏览器打开
**缺点：** 长链接会撑大画布

---

## 方案 3：交付消息附带链接（推荐，与方案1/2配合）

在 agent 的回复消息中，提供结构化的链接清单，画板只负责可视化。

**agent 回复示例：**
```
画板已生成 ✅

📄 文档链接：
  • 文档A「Agent & PMO 学习文档索引」
    https://bytedance.sg.larkoffice.com/docx/KZlbdMZF...
  • 文档B「TTADK 实战指南」
    https://bytedance.sg.larkoffice.com/wiki/G7RcwK0S...

💡 画板中标注的「KZlbdMZF...」等 token 即为文档 ID 的一部分，
   可直接在飞书中搜索定位。
```

---

## 数据结构更新

### DocNode meta 字段

```json
{
  "id": "h1-1",
  "title": "第一章",
  "meta": {
    "doc_title": "文档A标题",
    "doc_url": "https://...",
    "doc_token": "KZlbdMZF...",
    "word_count": 2000,
    "has_table": false,
    "has_code": false,
    "section_url": "https://...#heading-xxx",
    "section_token": "heading-block-token"
  }
}
```

### 多文档关联 meta

```json
{
  "cross_doc_relations": [
    {
      "from_doc": "KZlbdMZF...",
      "from_title": "文档A",
      "from_section": "h1-2",
      "to_doc": "G7RcwK0S...",
      "to_title": "文档B",
      "to_section": "h1-1",
      "type": "reference",
      "description": "引用了文档B的方案设计",
      "from_url": "https://...",
      "to_url": "https://..."
    }
  ]
}
```

---

## 实现优先级

| 优先级 | 方案 | 适用场景 |
|--------|------|---------|
| P0 | 方案 1（节点标注短 token） | 所有画板，始终执行 |
| P0 | 方案 3（消息附带链接） | agent 回复时附带 |
| P1 | 方案 2（底部完整链接） | 文档数 ≤ 3 时 |

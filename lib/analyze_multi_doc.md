# 多文档关联分析指令

> 这是给 LLM 的 prompt 模板，用于分析多个飞书文档之间的结构关联。

## 输入

多个文档的结构解析结果（parse_structure.md 输出的 JSON 数组）。

## 输出格式

```json
{
  "documents": [
    {
      "doc_title": "文档A标题",
      "doc_token": "tokenA",
      "focus_range": "全部",
      "structure": { ... }
    },
    {
      "doc_title": "文档B标题",
      "doc_token": "tokenB",
      "focus_range": "第2-4章",
      "structure": { ... }
    }
  ],
  "cross_doc_relations": [
    {
      "from_doc": "tokenA",
      "from_section": "h1-2",
      "to_doc": "tokenB",
      "to_section": "h1-1",
      "type": "reference",
      "description": "文档A的第2章引用了文档B的第1章概念",
      "strength": "strong"
    },
    {
      "from_doc": "tokenA",
      "from_section": "h1-3",
      "to_doc": "tokenB",
      "to_section": "h1-3",
      "type": "parallel",
      "description": "两文档的第3章讨论同一主题的不同方面",
      "strength": "medium"
    },
    {
      "from_doc": "tokenA",
      "from_section": "h1-1",
      "to_doc": "tokenB",
      "to_section": "h1-2",
      "type": "conflict",
      "description": "两文档对该问题存在观点差异",
      "strength": "weak"
    }
  ],
  "common_themes": [
    {
      "theme": "共同主题名称",
      "sections": [
        {"doc": "tokenA", "section": "h1-2"},
        {"doc": "tokenB", "section": "h1-1"}
      ]
    }
  ],
  "summary": "多文档结构关联的整体概述（2-3句话）"
}
```

## 关联类型

| type | 含义 | 画板表现 |
|------|------|---------|
| `reference` | 引用/参照 | 虚线箭头 |
| `parallel` | 并列/对比（讨论同一主题） | 双向箭头 |
| `conflict` | 冲突/差异 | 红色箭头 |
| `complement` | 互补/补充 | 绿色箭头 |
| `sequence` | 前后依赖/递进 | 实线箭头 |
| `contains` | 包含/子集 | 无箭头线 |

## 强度等级

| strength | 含义 | 画板表现 |
|----------|------|---------|
| `strong` | 强关联 | 粗线（3px） |
| `medium` | 中关联 | 中线（2px） |
| `weak` | 弱关联 | 细线（1px） |

## 分析规则

1. **先解析后关联**：每个文档先独立完成结构解析，再做跨文档关联
2. **用户关注范围**：如果用户指定了每个文档的关注范围，只对关注范围内的内容做关联
3. **关联数量控制**：每个章节最多标记 3 个跨文档关联，避免画板过于复杂
4. **摘要精炼**：每条关联描述不超过 30 字
5. **共同主题提取**：识别所有文档中都涉及的核心主题

# 文档结构解析指令

> 这是给 LLM 的 prompt 模板，用于分析飞书文档的结构。

## 输入

飞书文档的 Markdown 内容（通过 `lark-cli docs +fetch` 获取）。

## 输出格式

输出结构化 JSON，供后续 SVG 画板生成使用。

```json
{
  "doc_title": "文档标题",
  "doc_token": "文档 token",
  "structure": {
    "outline": [
      {
        "id": "h1-1",
        "level": 1,
        "title": "第一章标题",
        "summary": "一句话概括该章节核心内容（≤50字）",
        "key_points": ["要点1", "要点2", "要点3"],
        "difficulty": "normal",
        "children": [
          {
            "id": "h2-1-1",
            "level": 2,
            "title": "1.1 小节标题",
            "summary": "一句话概括",
            "key_points": ["要点"],
            "difficulty": "hard",
            "children": []
          }
        ]
      }
    ],
    "relations": [
      {
        "from": "h1-1",
        "to": "h2-1-1",
        "type": "contains",
        "description": "包含关系"
      },
      {
        "from": "h1-1",
        "to": "h1-2",
        "type": "causal",
        "description": "因果关系：前者导致后者"
      }
    ],
    "highlights": {
      "key_concepts": ["核心概念1", "核心概念2"],
      "difficult_sections": ["h2-1-1"],
      "cross_references": ["参见第三章相关内容"]
    }
  }
}
```

## 解析规则

1. **层级识别**：根据 Markdown 的 `#` 数量确定标题层级
2. **摘要生成**：每个章节用一句话概括核心内容，不超过 50 字
3. **要点提取**：每章节提取 2-5 个关键要点
4. **难度标记**：`easy` / `normal` / `hard`，基于内容复杂度判断
5. **关系识别**：识别章节间的逻辑关系：
   - `contains`：父子包含（大纲层级）
   - `causal`：因果关系
   - `parallel`：并列/对比关系
   - `sequential`：递进/顺序关系
   - `reference`：交叉引用
6. **重点标记**：识别核心概念和难点章节
7. **精简原则**：层级过深时（>4层）合并底层节点，保持画板可读性

## 用户裁剪

如果用户指定只解析文档的某一部分：
- 只输出指定章节及其子节点的结构
- 其他章节标记为 `collapsed: true`，不展开 children
- relations 中不包含被裁剪部分的关联

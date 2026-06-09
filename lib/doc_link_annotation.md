# 文档链接标注方案

> 在画板中标注文档来源，让用户能识别并追溯。

## 核心约束

**RULES.md 禁止在画板上写 source citations、tokens、file paths。** 因此画板内不做"可点击链接"，只做最小标识 + agent 消息中给完整链接。

## 标注策略（三层）

| 层级 | 位置 | 内容 | 谁来执行 |
|------|------|------|---------|
| **L1 画板标识** | 文档标题栏（深色区域）内 | 灰色 9px 小字：token 前 8 位 + `...` | SVG 生成时 |
| **L2 关联高亮** | 有跨文档关联的章节节点 | 用 placeholder 色填充 + 加粗边框 | SVG 生成时 |
| **L3 完整链接** | Agent 回复消息 | 文档标题 + 完整飞书 URL + 关联说明 | 交付时 |

## L1 画板标识规范

每个文档列的标题栏（`fill: ink-black` 区域），在标题文字下方追加一行灰色小字：

```xml
<rect x="30" y="100" width="540" height="60" rx="6" fill="#1A1A16"/>
<text x="300" y="130" text-anchor="middle" font-size="18" font-weight="bold" fill="#FAFADF">OpenClaw 一键打通研发全流程</text>
<text x="300" y="148" text-anchor="middle" font-size="9" fill="#8A8A80">J1pWdBJB...</text>
```

**注意：**
- 只写 token 前 8 位 + `...`，不写完整 URL
- 只在标题栏写一次，不在每个 H1 节点重复标注
- 不写 📄 图标前缀（RULES.md 禁止装饰性元素）

## L2 关联高亮规范

存在跨文档关联的章节节点，用以下视觉区分：
- 填充色：`cream-paper-3`（Monochrome 风格）或对应风格的 placeholder 色
- 边框：`stroke-width: 1`（普通节点是 0.5）
- 节点文本中标注：`← 关联文档X`

## L3 交付消息格式

```
画板已生成 ✅

📄 源文档：
  • OpenClaw 一键打通研发全流程
    https://bytedance.larkoffice.com/docx/J1pWdBJB...
  • LLMBox 一键接入 SOTA 模型
    https://bytedance.larkoffice.com/docx/LclTdTjL...
  • Hermes 接入 LLMBox 配置教程
    https://bytedance.sg.larkoffice.com/docx/JNCzdD5d...

🔗 跨文档关联：
  • A 快速上手 → B 概述（A 使用 B 作为模型服务）
  • C Step1 方式A → A（C 依赖 A 安装 gdpa_openclaw）
  • C Step1 方式B → B（C 依赖 B llmbox 缓存）
```

## 数据层

DocNode meta 必须保留完整信息供 L3 使用：
```json
{
  "meta": {
    "doc_title": "完整标题",
    "doc_url": "完整飞书链接",
    "doc_token": "token"
  }
}
```

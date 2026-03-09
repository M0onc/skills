---
name: x-to-notebooklm
description: 将 X (Twitter) 文章解析并上传到 NotebookLM。使用 r.jina.ai 抓取内容，自动创建 Notebook 并上传文章。
---

# X to NotebookLM

将 X (Twitter) 文章快速解析并上传到 Google NotebookLM，便于深度阅读和分析。

## 依赖项

- **r.jina.ai** - 免费的网页内容提取服务（无需 API Key）
- **NotebookLM CLI** - 已安装并认证（运行 `notebooklm login` 完成认证）
- **Node.js** - 运行脚本环境

## 使用方法

### 基本用法

```bash
# 从工作区根目录运行
node ~/.openclaw/workspace/skills/x-to-notebooklm/scripts/x-to-notebooklm.mjs <X文章URL>

# 示例
node ~/.openclaw/workspace/skills/x-to-notebooklm/scripts/x-to-notebooklm.mjs "https://x.com/elonmusk/status/1234567890"
```

### 带参数用法

```bash
# 指定 Notebook 名称
node ~/.openclaw/workspace/skills/x-to-notebooklm/scripts/x-to-notebooklm.mjs <URL> --notebook-name "X Articles"

# 使用现有 Notebook
node ~/.openclaw/workspace/skills/x-to-notebooklm/scripts/x-to-notebooklm.mjs <URL> --notebook-id <existing_notebook_id>

# 详细输出模式
node ~/.openclaw/workspace/skills/x-to-notebooklm/scripts/x-to-notebooklm.mjs <URL> --verbose
```

## 工作流程

1. **抓取内容** - 使用 `curl + r.jina.ai` 提取 X 文章的纯文本内容
2. **创建 Notebook** - 自动创建新的 NotebookLM Notebook（或复用现有的）
3. **上传文章** - 将解析后的内容作为 Source 上传到 Notebook
4. **验证效果** - 检查上传状态并返回 Notebook ID 和 Source ID

## 输出示例

```
✅ X 文章解析上传成功

📄 文章标题：Elon Musk on X: "..."
🔗 原始链接：https://x.com/elonmusk/status/1234567890
📓 Notebook ID: notebook_abc123
📝 Source ID: source_xyz789
📊 解析状态：已处理完成
```

## 配置要求

### 环境变量（可选）

```bash
# 默认 Notebook 名称（如不指定 --notebook-name）
export NOTEBOOKLM_DEFAULT_NOTEBOOK="X Articles"

# 详细模式
export X_TO_NOTEBOOKLM_VERBOSE=true
```

### NotebookLM 认证

首次使用前需要认证：

```bash
# 使用 NotebookLM CLI 登录
node ~/.openclaw/skills/tiangong-notebooklm-cli/scripts/notebooklm.mjs login
```

## 故障排除

### 常见问题

**Q: 提示 "NotebookLM CLI not authenticated"**
```bash
# 运行登录命令
node ~/.openclaw/skills/tiangong-notebooklm-cli/scripts/notebooklm.mjs login
```

**Q: r.jina.ai 无法访问 X 文章**
- 检查 URL 是否正确
- X 文章可能需要登录才能访问
- 尝试使用已登录的浏览器会话
- **注意**：X (Twitter) 大部分内容现在需要登录，r.jina.ai 可能无法抓取需要登录的内容
- 替代方案：使用 browser 工具配合已登录的浏览器会话

**Q: 脚本执行超时**
- 增加超时时间：添加 `--timeout 60` 参数
- 检查网络连接

**Q: Source ID 显示为 "pending"**
- 这是正常现象，NotebookLM 正在处理上传的内容
- 等待几分钟后在 NotebookLM 界面中查看

### X 文章抓取限制

由于 X (Twitter) 在 2023 年后实施了更严格的访问限制：

- ✅ **公开文章** - r.jina.ai 可以抓取
- ⚠️ **需要登录的文章** - r.jina.ai 无法抓取
- 💡 **解决方案** - 使用 browser 工具配合已登录的浏览器会话，或手动复制内容

### 测试结果

**测试时间**: 2026-03-07 23:46 (北京时间)  
**测试 URL**: https://github.com/openclaw/openclaw  
**测试结果**: ✅ 成功

```
📓 Notebook ID: 6367c115-bcfa-42f3-b174-456df3537122
📝 Source ID: 658c3733-a02f-4b08-ae16-fc06475d1c19
📊 解析状态：processed
```

## 相关文件

- 主脚本：`scripts/x-to-notebooklm.mjs`
- 元数据：`_meta.json`
- NotebookLM CLI 文档：`~/.openclaw/skills/tiangong-notebooklm-cli/references/cli-commands.md`

## 版本历史

- **v1.0.0** (2026-03-07) - 初始版本
  - 支持 X 文章抓取
  - 自动创建 Notebook
  - 上传并验证

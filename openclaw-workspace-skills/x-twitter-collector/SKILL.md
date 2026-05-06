---
name: x-twitter-collector
description: >
  X/Twitter推文收集技能。自动收集指定用户过去24小时内的所有推文（原创+转帖），
  生成包含中英双语、截图、链接和数据分析的完整报告。当用户要求收集推文、
  监控Twitter/X动态、生成推文摘要报告时使用。参数：@用户名（必填）。
---

## 前置条件
1. **浏览器已配置**：OpenClaw 浏览器工具可用
2. **X 账号登录**：建议登录 X 账号以获取完整内容（未登录可能有内容限制）
3. **目标用户公开**：目标 X 账号必须是公开账号

## 使用方法

### 基础用法
```
收集 @用户名 过去 24 小时的推文
```

### 完整命令示例
```
帮我收集 @elonmusk 过去 24 小时的推文，要中英双语和截图
```

### 参数说明
| 参数 | 说明 | 默认值 |
|------|------|--------|
| `@用户名` | X 账号用户名（不含 @ 也可） | 必填 |
| `时间范围` | 过去多少小时的内容 | 24 小时 |
| `语言` | 报告语言 | 中英双语 |
| `截图` | 是否包含页面截图 | 是 |
| `链接` | 是否包含推文直链 | 是 |

## 操作流程

### 步骤 1: 打开浏览器
```javascript
browser.start({ profile: "openclaw" })
```

### 步骤 2: 访问用户主页
```javascript
browser.open({ 
  profile: "openclaw", 
  targetUrl: "https://x.com/{username}" 
})
```

### 步骤 3: 等待页面加载
```javascript
browser.act({ 
  profile: "openclaw",
  request: { kind: "wait", timeMs: 5000 },
  targetId: "{targetId}"
})
```

### 步骤 4: 获取页面快照
```javascript
browser.snapshot({ 
  profile: "openclaw", 
  refs: "aria", 
  targetId: "{targetId}" 
})
```

### 步骤 5: 滚动加载更多内容
```javascript
browser.act({ 
  profile: "openclaw",
  request: { kind: "evaluate", fn: "window.scrollTo(0, document.body.scrollHeight)" },
  targetId: "{targetId}"
})
```

### 步骤 6: 获取页面截图
```javascript
browser.screenshot({ 
  profile: "openclaw", 
  fullPage: true, 
  targetId: "{targetId}",
  type: "png"
})
```

### 步骤 7: 解析和整理数据
从快照中提取：
- 推文内容（中英文）
- 发布时间
- 互动数据
- 推文链接
- 区分原创/转帖

### 步骤 8: 生成报告
按照预设模板生成完整的中英双语报告。

## 输出内容

### 报告结构
1. **数据概览** - 推文数量统计表格
2. **原创推文** - 每条包含：
   - 中英双语对照表格
   - 发布时间和内容
   - 互动数据（回复/转帖/点赞/浏览）
   - 推文直链
3. **转帖列表** - 表格形式展示
4. **主题分析** - 按内容分类统计
5. **数据汇总** - 总计数据
6. **页面截图** - 完整长截图

## 数据解析规则

### 原创推文识别
- 不包含 "已转帖" / "Retweeted" 标识
- 用户头像和名称直接显示

### 转帖识别
- 包含 "已转帖" / "Retweeted" 标识
- 显示原始推文作者

### 互动数据解析
- 回复数：💬 或 "回复"
- 转帖数：🔄 或 "转帖"
- 点赞数：❤️ 或 "喜欢"
- 浏览数：👁️ 或 "次浏览"

## 故障排除

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 浏览器无法启动 | 浏览器配置问题 | 检查 `browser status` |
| 内容加载不全 | 页面未完全加载 | 增加等待时间或手动滚动 |
| 截图失败 | 内存不足 | 关闭 fullPage 或分屏截图 |
| 链接无效 | 推文已删除 | 标注为"不可用" |

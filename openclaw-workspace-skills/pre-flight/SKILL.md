---
name: pre-flight
description: >
  Pre-flight interview before executing complex tasks. Use when the user asks
  for research, reports, analysis, code projects, system design, product design,
  or any multi-step task where assumptions could lead to wrong output. Trigger
  phrases include: "帮我写", "帮我调研", "帮我分析", "做个报告", "设计一个",
  "帮我做个", "帮我搞", "build", "research", "analyze", "design", "report".
  Do NOT use for simple Q&A, quick fixes, or single-file edits.
metadata: {"pattern": "inversion", "interaction": "multi-turn", "max-rounds": "3"}
---

你正在执行 Pre-flight 信息收集流程。在所有阶段完成之前，**不要**开始执行任务。不要猜测用户意图，不要提前输出结果。

## 流程规则

- 每轮提出一组问题（不限个数，想到多少问多少）
- 用户回答后进入下一轮
- 最多 3 轮，3 轮后必须进入执行阶段
- 如果某轮中用户明确表示"就这样了"或"没了"，提前结束提问
- 用中文提问和交流

## Phase 1 — 任务定位

搞清楚用户到底要什么。问以下方面（根据任务类型选取相关的问题）：

**通用问题：**
- 这个任务的核心目标是什么？你希望最终产出物解决什么问题？
- 有没有你已经有的材料、数据、参考资料？可以发给我。
- 有没有你觉得"肯定不要"的东西？（比如不要某个风格、不要某个方向、不要某类内容）

**报告/调研类附加：**
- 目标受众是谁？（给老板看/给技术团队看/给自己备忘/对外发布？）
- 深度预期？（快速 overview / 标准分析 / 深度研究报告？）

**代码/工程类附加：**
- 技术栈偏好或约束？（语言、框架、部署环境？）
- 是从零开始还是在已有代码基础上修改？

**设计类附加：**
- 有没有参考案例或风格偏好？
- 最终交付形式？（文档/PPT/原型/代码？）

## Phase 2 — 范围与优先级

在 Phase 1 回答的基础上，进一步明确边界：

- 产出物的详细程度/篇幅预期？（几百字摘要 / 几千字报告 / 完整文档？）
- 有没有时间或轮次上的限制？（比如"先给我一个初版就行"vs"要一次到位"）
- 这个任务里你觉得最重要的部分是哪个？如果时间不够，哪个部分可以砍？
- 有没有你特别想在结果里看到的分析角度或切入点？

## Phase 3 — 确认与兜底

收尾确认，确保没有遗漏：

- 基于前两轮的信息，我理解的任务是：[用一句话复述]。对吗？
- 有没有上两轮没覆盖到、但你觉得重要的补充？
- 你希望我产出中间 draft 给你看，还是一步到位给最终版？

## 进入执行

三个阶段全部完成后，在回复开头用以下格式标记收齐信息，然后开始执行：

```
✅ Pre-flight 完成，开始执行。
```

如果用户在任意阶段说"直接开始吧"或类似意思，立即停止提问，进入执行。

# gstack

所有网页浏览任务都使用 gstack 的 `/gstack-browse` skill。**禁止**使用 `mcp__claude-in-chrome__*` 系列工具。

可用的 gstack skills：`/gstack-office-hours`、`/gstack-plan-ceo-review`、`/gstack-plan-eng-review`、`/gstack-plan-design-review`、`/gstack-design-consultation`、`/gstack-design-shotgun`、`/gstack-design-html`、`/gstack-review`、`/gstack-ship`、`/gstack-land-and-deploy`、`/gstack-canary`、`/gstack-benchmark`、`/gstack-benchmark-models`、`/gstack-browse`、`/gstack-connect-chrome`、`/gstack-qa`、`/gstack-qa-only`、`/gstack-design-review`、`/gstack-setup-browser-cookies`、`/gstack-setup-deploy`、`/gstack-setup-gbrain`、`/gstack-retro`、`/gstack-investigate`、`/gstack-document-release`、`/gstack-document-generate`、`/gstack-codex`、`/gstack-cso`、`/gstack-autoplan`、`/gstack-plan-devex-review`、`/gstack-devex-review`、`/gstack-careful`、`/gstack-freeze`、`/gstack-guard`、`/gstack-unfreeze`、`/gstack-upgrade`、`/gstack-learn`、`/gstack-health`、`/gstack-scrape`、`/gstack-spec`、`/gstack-skillify`、`/gstack-pair-agent`、`/gstack-plan-tune`、`/gstack-landing-report`、`/gstack-make-pdf`、`/gstack-open-gstack-browser`、`/gstack-ios-clean`、`/gstack-ios-fix`、`/gstack-ios-qa`、`/gstack-ios-sync`、`/gstack-ios-design-review`、`/gstack-sync-gbrain`、`/gstack-context-save`、`/gstack-context-restore`。

# 核心偏好

- 无论参考资料语种，回复统一使用中文，技术术语保留英文原文
- 不用 emoji
- 代码注释用英文

# 写作规范

## 区分产品文档与工程文档

写文档前先判断类型，二者的语言要求相反：

- **产品文档**（PRD、User Story、用户手册、README、营销材料、Release Notes）
  目标读者是产品 / 设计 / 业务 / 终端用户；去术语、用人话、求精简。
- **工程文档**（架构设计、API 规范、技术方案、开发计划、CLAUDE.md、内部 RFC、测试策略、决策记录）
  目标读者是开发者；保留 term、求精确、结构密度高。

类型不明时主动询问。README 按实际读者归类，不按文件名。

## 产品文档的语言基线

1. **避免把实现细节当产品描述**。"落盘 / 写盘 / 阻断 / 魔数"指向代码层面，产品文档改用用户视角的词："保存 / 阻止 / 固定阈值"。没有干净对应词的（如"接缝"），不要硬找替换词，直接重写整句，描述用户看到或经历的结果。
2. **不造词、不用空泛套话**。不发明"硬 MVP 边界 / 强制前置"这类临时复合词，也不用"完整愿景 / 卓越体验 / 一站式 / 赋能"这类空泛大词。改为具体范围、步骤、或用户能直接看到的结果。
3. **必要技术词要说明**。无法避免的技术词，第一次出现用"中文 (English)"形式，如"系统密钥库 (OS keychain)"；之后用其中更通用的那个（有 acronym 用 acronym，没有就用 English 原词）。已是行业通用词的（commit / schema / API / frontmatter）直接用 English，不硬翻成生硬中文。
4. **每段写完自检**。问自己："产品经理或终端用户读到这句会卡壳吗？"如果读者必须懂实现、依赖额外上下文、或要猜术语含义才能读懂，就重写。

## 工程文档的语言基线

1. **术语沿用已有命名，不临时造词**。代码库、协议或团队已有 `session` / `workspace` / `artifact`，不要写成"会话体 / 工作域 / 产物件"；确实需要新术语时先定义边界。
2. **Acronym 首次出现必须展开**。用"访问控制列表 (Access Control List, ACL)"，后文再用 `ACL`；不要假设读者都懂内部缩写。
3. **结构优先于修辞，段落密度要高**。架构 / RFC / ADR 先写清 scope、constraints、decision、trade-off、failure mode；API spec、测试策略用列表或表格承载字段、状态码、case matrix。
4. **中文解释，English 保留精确技术对象**。概念说明和决策理由用中文；code identifier、CLI flag、HTTP header、error code、config key、library、protocol term 保持 English。
5. **避免空泛动词，写成可验证的工程事实**。不写"优化稳定性 / 完善链路 / 保障体验"，改写为"retry 3 次后返回 `TIMEOUT`""P95 latency 低于 200ms""失败时进入 fallback path"。
6. **依赖与顺序写成结构陈述，不写"等 X 才能 Y"条件句**。"等 X 做出来才能做 Y"是 "cannot proceed until X" 的翻译腔；改写为"Y 依赖 X，排在其后"。
7. **状态用事实锚定，不用情绪 / 评价词**。历史或未落地给版本号，不用"一直 / 却 / 始终 / 终于"（"定位里写了却一直没落地"→"DESIGN.md 已规划，v0.1–v0.1.5 未落地"）；不做无基准的价值 / 风险排序，删掉"最低 / 最优 / 最关键"而非补指标。

## 定稿前用 humanizer-zh 自查

PRD、User Story、技术文档、开发计划是 AI 痕迹高发区，定稿前用 humanizer-zh skill 过一遍，重点清掉夸大意义、提纲式套路、三段式 / 否定式排比、模糊归因、空泛积极结论、填充与过度限定。标题括号只允许术语对照（"国际化（i18n）"）和版本 / 平台 / 范围限定（"（v0.1）""(Windows)"），其余不写。

用 humanizer-zh 时两条例外：
- "注入灵魂 / 个性"一节（第一人称、主观抒情、允许跑题）是给随笔博客的，这几类文档要精确中性，跳过。
- 样式规则（"粗体过度""内联标题列表"）按需判断：靠小标题和列表撑结构，只删机械滥用，别删必要结构。

# 编码习惯

- 变量命名：TypeScript 用 camelCase，Python 用 snake_case
- 函数不建议超过 50 行，超过就拆
- 不主动引入新的第三方依赖

# Git 约定

- commit message 用英文，格式：`type(scope): description`
- 不要自动 push，等用户确认
- 不要用 `git checkout` / `git restore` 撤回改动

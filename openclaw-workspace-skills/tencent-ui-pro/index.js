/**
 * Tencent UI Pro - 腾讯风格UI生成技能核心逻辑
 */

const TENCENT_DESIGN_SPEC = (theme = 'dark') => `
## 腾讯QQ Design设计规范强制要求：
### 配色必须使用以下变量：
${theme === 'dark' ? `
/* 深色主题 */
--bg: #12131a;
--panel: #1a1d26;
--panel-soft: #232836;
--border: #30384a;
--text: #f2f5fb;
--muted: #9aa4bd;
--accent-soft: rgba(37, 176, 217, 0.15);
--accent-hover: rgba(37, 176, 217, 0.25);
--shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.15);
--shadow-md: 0 4px 16px rgba(0, 0, 0, 0.2);
--shadow-lg: 0 8px 24px rgba(0, 0, 0, 0.25);
` : `
/* 日间（浅色）主题 */
--bg: #ffffff;
--panel: #f7f8fa;
--panel-soft: #f2f3f5;
--border: #e5e6eb;
--text: #1d2129;
--muted: #86909c;
--accent-soft: rgba(37, 176, 217, 0.1);
--accent-hover: rgba(37, 176, 217, 0.18);
--shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.08);
--shadow-md: 0 4px 16px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 8px 24px rgba(0, 0, 0, 0.12);
`}
/* 通用配色（深浅主题统一） */
--accent: #25b0d9;
--good: #ff4d67;
--success: #00b42a;
--warning: #ff7d00;
--danger: #f53f3f;

### 字体必须使用以下规范：
标题字重统一为600，正文字重400，行高1.5
--font-size-h1: 24px;
--font-size-h2: 20px;
--font-size-h3: 16px;
--font-size-body: 14px;
--font-size-small: 12px;

### 圆角规范：
--radius-sm: 8px;
--radius-md: 12px;
--radius-lg: 16px;
--radius-xl: 20px;

### 交互规范：
所有可点击元素hover时必须有轻微上浮+阴影变化+边框高亮为主题色，过渡动画时长140-240ms
`;

async function generateUI(prompt, config = {}) {
  const { theme = 'dark', outputFramework = 'html' } = config;
  
  // 拼接生成prompt，强制注入腾讯设计规范
  const fullPrompt = `
    ${prompt}
    
    输出要求：
    1. 严格遵循以下腾讯QQ Design设计规范，不得违反
    ${TENCENT_DESIGN_SPEC(theme)}
    2. 所有颜色、字体、圆角、阴影必须使用上述CSS变量定义
    3. 输出${outputFramework}格式的完整代码
    4. 代码必须结构清晰，注释完整，可直接运行
    5. 界面必须美观，符合现代设计审美，避免AI生成的通用平庸风格
  `;
  
  // 调用frontend-design技能生成代码
  const frontendDesignSkill = require('../frontend-design');
  const result = await frontendDesignSkill.generate(fullPrompt, {
    framework: outputFramework,
    theme: theme
  });
  
  return result;
}

module.exports = {
  generateUI
};

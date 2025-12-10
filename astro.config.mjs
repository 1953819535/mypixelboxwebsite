import { defineConfig } from 'astro/config';

// 对于自定义域名，base 应该设置为 '/'
export default defineConfig({
  // 1. 明确输出为静态网站
  output: 'static',

  // 2. 设置基础路径为根路径，适用于自定义域名部署
  base: '/',

  // 3. 构建配置
  build: {
    format: 'file',
  },
  
  // 4. 不生成带斜杠的文件夹路径
  trailingSlash: 'never'
});
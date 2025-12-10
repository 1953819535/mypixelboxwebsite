import { defineConfig } from 'astro/config';

// 获取仓库名称用于 GitHub Pages 部署
const repositoryName = process.env.GITHUB_REPOSITORY?.split('/')[1] || '';

export default defineConfig({
  // 1. 明确输出为静态网站
  output: 'static',

  // 2. 设置基础路径为仓库名称，适用于 GitHub Pages 部署
  base: `/${repositoryName}/`,

  // 3. 构建配置
  build: {
    format: 'file',
  },
  
  // 4. 不生成带斜杠的文件夹路径
  trailingSlash: 'never'
});
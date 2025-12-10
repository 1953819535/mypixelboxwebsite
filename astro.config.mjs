import { defineConfig } from 'astro/config';

export default defineConfig({
  // 1. 明确输出为静态网站
  output: 'static',

  // 2. 这是生成相对路径的核心指令
  base: './',

  // 3. 这是确保 `base` 指令能被正确执行的关键辅助设置
  build: {
    format: 'file',
    // 确保静态资源也使用相对路径
    assetsPrefix: './'
  },
  
  // 4. 加上这个，确保不会生成文件夹形式的路径，进一步简化路径计算
  trailingSlash: 'never'
});
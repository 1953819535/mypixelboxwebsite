import axios from 'axios';
import fs from 'fs';
import path from 'path';

// 从环境变量获取API基础URL
const API_BASE_URL = process.env.VITE_API_BASE_URL || 'http://localhost:3000';

export async function fetchAlbums() {
  try {
    console.log('正在获取相册数据...');
    
    // 从真实API获取数据
    const response = await axios.get(`${API_BASE_URL}/api/albums/gallery/local`);
    const apiData = response.data;
    
    // 检查API响应是否成功
    if (apiData.code !== 0) {
      throw new Error(apiData.message || 'API请求失败');
    }
    
    // 处理数据
    const albums = apiData.data.map(album => ({
      ...album,
      photos: album.photos.map(photo => ({
        ...photo,
        // 保持原始数据结构
      }))
    }));
    
    // 确保数据目录存在
    const dataDir = path.join(process.cwd(), 'src', 'data');
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }
    
    // 保存数据到本地文件
    const dataFilePath = path.join(dataDir, 'albums.json');
    fs.writeFileSync(dataFilePath, JSON.stringify(albums, null, 2));
    
    console.log(`成功获取 ${albums.length} 个相册，数据已保存到 ${dataFilePath}`);
    return true;
  } catch (err) {
    console.error('获取相册数据失败:', err.message);
    return false;
  }
}

// 如果直接运行此脚本，则执行fetchAlbums函数
if (import.meta.url === `file://${process.argv[1]}`) {
  fetchAlbums().then(success => {
    if (!success) {
      process.exit(1);
    }
  });
}
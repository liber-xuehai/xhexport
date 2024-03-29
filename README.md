# xhexport

学海数据目录解析 & 数据导出项目。

本项目仅供学习交流使用，请在下载后的 24h 内删除。

## Usage

### 构建（本地构建）

请将学海的数据目录 `xuehai` 置于同目录下，这个目录通常位于设备的 `/storage/emulated/0/xuehai`。

1. 将 `config.sample.yml` 拷贝为 `config.yml` 并进行配置
2. 执行 `python xuehai.py build`

### 运行 HTTP 服务器

1. 执行 `python xuehai.py server`（推荐）
2. 或者使用任意 Simple HTTP Server 工具，以项目目录为根目录启动服务

## Features

### 后端

- [x] 响应数据导出
- [x] 云课堂数据导出
- [x] 云课堂课件转换
- [x] 云作业数据导出
- [x] 云课堂答案导出
- [x] 资料中心数据导出
- [ ] 新字典数据导出（**Help needed**：需反编译出数据库表名）
- [ ] 学海题舟数据导出（**Help needed**：题面数据被加密）

### 前端

- [x] 前端框架（CoffeeScript）
- [x] 课件转换为长网页或 PDF

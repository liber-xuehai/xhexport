# open-xuehai

学海数据目录解析 & 数据导出项目。

该项目名是为致敬 Github 上某些前人的研究，是他们的未竟之业促成了这个项目的诞生，不过处于产权保护等原因，这里并不会对此提供具体补充。

### Usage

#### 构建（本地构建）

请将学海的数据目录 `xuehai` 置于同目录下，这个目录通常位于设备的 `/storage/emulated/0/xuehai`。

1. 将 `config.sample.yml` 拷贝为 `config.yml` 并进行配置
2. 执行 `python xuehai.py build`

#### 运行 HTTP 服务器

1. 执行 `python xuehai.py server`（推荐）
2. 或者使用任意 Simple HTTP Server 工具，以项目目录为根目录启动服务

### Features

- [x] 响应数据导出
- [x] 云课堂数据导出
- [x] 云课堂课件转换
- [x] 云作业数据导出
- [ ] 资源中心数据导出
- [ ] 学海题舟数据导出
- [x] 前端
- [x] 前端课件转换为长网页或 PDF
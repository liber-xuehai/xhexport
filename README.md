# open-xuehai

学海数据目录解析 & 数据导出项目。

该项目名本意是为了致敬前人的某些研究，是他们的研究产物促成了这个项目的诞生，不过这里并不会提供研究结果的补充。

### Usage

#### 构建（本地构建）

请将学海的数据目录 `xuehai` 置于同目录下，这个目录通常位于设备的 `/storage/emulated/0/xuehai`。

1. 将 `config.sample.yml` 拷贝为 `config.yml` 并进行配置
2. 执行 `python build.py`

#### 运行 HTTP 服务器

1. 执行 `python server.py`（推荐）
2. 或者使用任意 Simple HTTP Server 工具，以项目目录为根目录启动服务

### Feature

- [x] 响应数据导出
- [x] 云课堂数据导出
- [x] 云作业数据导出
- [ ] 学海题舟数据导出
- [x] 前端
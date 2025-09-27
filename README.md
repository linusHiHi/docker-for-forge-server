# Docker for Forge Server

用于构建和部署 Minecraft Forge 模组服务器的 Docker 化解决方案。

## 环境要求

- Docker 和 Docker Compose
- Fish Shell（用于构建脚本）
- Linux/macOS 环境

## 项目结构

```text
.
├── build_and_push.fish     # 构建和推送脚本
├── docker-compose.yml      # 本地构建配置
├── dockerfile              # Docker 镜像定义
├── .env                    # 环境变量配置
├── packs/                  # 模组包目录
│   └── [PACK_NAME]/        # 具体的模组包
└── server_config/          # 服务器部署配置
    ├── docker-compose.yml  # 生产环境配置
    └── data/               # 数据持久化目录
        └── modified_data/ # 自定义配置文件
```

## 配置说明

### .env 文件配置

修改 `.env` 文件以适配你的模组包：

```bash
PACK_NAME=Planetary                    # 模组包名称
JAVA_VERSION=8                         # Java版本
MC_VERSION=1.12.2                      # Minecraft版本
FORGE_VERSION=14.23.5.2860            # Forge版本
DOCKER_HUB_PREFIX=your-registry/repo   # Docker镜像仓库前缀
```

## 构建过程

1. 将模组包解压到 `packs/` 文件夹，确保文件夹名与 `.env` 中的 `PACK_NAME` 一致
2. 修改 `.env` 文件为对应的版本信息
3. 运行构建脚本：

   ```bash
   ./build_and_push.fish <image_version>
   ```

## 部署

1. 将 `server_config/` 目录复制到服务器
2. 按需修改 `data/modified_data/user_jvm_args.txt` 调整 JVM 参数
3. 启动服务器：

   ```bash
   cd server_config
   docker-compose up -d
   ```

## 数据持久化

- `./data/world/` - 游戏世界存档
- `./data/modified_data/` - 自定义配置文件

## 注意事项

- 确保服务器有足够的内存（默认配置需要至少 2GB，建议 10GB）
- 首次启动可能需要较长时间来生成世界
- 修改配置后需要重启容器使其生效

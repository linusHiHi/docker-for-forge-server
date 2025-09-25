# 本地安装包使用指南

## 目录结构

```
local/
├── installers/                    # 存放本地安装包
│   ├── forge-1.18.2-40.2.4-installer.jar
│   └── forge-1.19.2-43.3.0-installer.jar
├── modpacks/                      # 存放整合包
│   └── Planetary-1.6.8.1.zip
├── world/                         # 世界存档
├── config/                        # 配置文件
├── mods/                          # 模组文件
├── dockerfile                     # Docker 配置文件
├── docker-compose.yml             # Docker Compose 配置
├── start.sh                       # 启动脚本
└── deploy.sh                      # 部署脚本
```

## 本地安装包使用方法

### 1. 准备安装包

创建 `installers` 目录并放入对应的 Forge 安装包：

```bash
mkdir -p installers
# 将你下载的 Forge 安装包放入此目录
cp /path/to/forge-1.18.2-40.2.4-installer.jar installers/
```

### 2. 支持的安装包命名格式

Docker 会自动识别以下命名格式的安装包：
- `forge-{MC_VERSION}-{FORGE_VERSION}-installer.jar`
- 例如: `forge-1.18.2-40.2.4-installer.jar`

### 3. 版本匹配规则

Docker 构建时会：
1. 首先检查 `installers/` 目录中是否存在对应版本的安装包
2. 如果存在，直接使用本地文件（节省下载时间）
3. 如果不存在，自动从官方下载

### 4. 自定义版本部署

编辑 `docker-compose.yml` 中的构建参数：

```yaml
build:
  context: .
  args:
    - JAVA_VERSION=17
    - MC_VERSION=1.18.2      # 修改 MC 版本
    - FORGE_VERSION=40.2.4   # 修改 Forge 版本
```

### 5. 常用版本安装包下载地址

#### Minecraft 1.18.2
- Forge 40.2.4: https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.2.4/forge-1.18.2-40.2.4-installer.jar
- Forge 40.2.10: https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.2.10/forge-1.18.2-40.2.10-installer.jar

#### Minecraft 1.19.2
- Forge 43.3.0: https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.2-43.3.0/forge-1.19.2-43.3.0-installer.jar
- Forge 43.3.13: https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.2-43.3.13/forge-1.19.2-43.3.13-installer.jar

#### Minecraft 1.20.1
- Forge 47.2.0: https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.2.0/forge-1.20.1-47.2.0-installer.jar
- Forge 47.3.0: https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.0/forge-1.20.1-47.3.0-installer.jar

### 6. 批量下载脚本

创建 `download-installers.sh` 脚本来批量下载常用版本：

```bash
#!/bin/bash
mkdir -p installers
cd installers

# 下载常用版本
wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.2.4/forge-1.18.2-40.2.4-installer.jar
wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.2-43.3.0/forge-1.19.2-43.3.0-installer.jar
wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.2.0/forge-1.20.1-47.2.0-installer.jar

echo "安装包下载完成！"
ls -la *.jar
```

### 7. 优势

使用本地安装包的优势：
- ✅ 避免重复下载，节省时间和带宽
- ✅ 离线环境下可以正常部署
- ✅ 网络不稳定时提高成功率
- ✅ 可以使用自定义或修改过的安装包
- ✅ 支持多版本快速切换

### 8. 注意事项

1. **文件名必须准确匹配**：`forge-{MC_VERSION}-{FORGE_VERSION}-installer.jar`
2. **版本号要与 docker-compose.yml 中的参数一致**
3. **确保安装包文件完整且可执行**
4. **installers 目录会被复制到容器中，避免放入过多文件**
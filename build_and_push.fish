#! /usr/bin/fish

# 获取命令行参数
set VERSION $argv[1]
if test -z "$VERSION"
    echo "错误: 请提供版本号"
    echo "用法: ./build_and_push.fish <版本号>"
    exit 1
end

# 读取环境变量文件
set -l env_file ".env"
if test -f $env_file
    for line in (cat $env_file)
        if test (string length $line) -gt 0; and not string match -q "#*" $line
            set -l key_value (string split "=" $line)
            set -gx $key_value[1] $key_value[2]
        end
    end
else
    echo "警告: 未找到 .env 文件，使用默认值"
    set -gx PACK_NAME "DeC"
end

echo "构建配置:"
echo "  PACK_NAME: $PACK_NAME"
echo "  VERSION: $VERSION"

# 构建镜像
echo "正在构建镜像..."
docker-compose -fdocker-compose.yml build

# 设置镜像名称
set LOCAL_IMAGE "forge-mc-server:$PACK_NAME-latest"
# docker pull crpi-vv1v4s4fdwh8q4xq.cn-hangzhou.personal.cr.aliyuncs.com/autsch/forge-mc-server:[镜像版本号]
set REMOTE_TAG "crpi-vv1v4s4fdwh8q4xq.cn-hangzhou.personal.cr.aliyuncs.com/autsch/forge-mc-server:$PACK_NAME-$VERSION"

# 标记镜像
echo "标记镜像: $LOCAL_IMAGE -> $REMOTE_TAG"
docker tag $LOCAL_IMAGE $REMOTE_TAG

# 推送镜像
echo "推送镜像: $REMOTE_TAG"
docker push $REMOTE_TAG

echo "构建和推送完成!"
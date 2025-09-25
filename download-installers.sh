#!/bin/bash

# Forge 安装包下载脚本

echo "======================================="
echo "  Forge 安装包下载工具"
echo "======================================="

# 创建 installers 目录
mkdir -p installers
cd installers

# 定义下载函数
download_forge() {
    local mc_version=$1
    local forge_version=$2
    local filename="forge-${mc_version}-${forge_version}-installer.jar"
    local url="https://maven.minecraftforge.net/net/minecraftforge/forge/${mc_version}-${forge_version}/${filename}"
    
    echo "📥 下载 ${filename}..."
    
    if [ -f "$filename" ]; then
        echo "✅ 文件已存在，跳过下载"
        return 0
    fi
    
    if curl -L -o "$filename" "$url"; then
        echo "✅ 下载完成: $filename"
        return 0
    else
        echo "❌ 下载失败: $filename"
        return 1
    fi
}

# 显示菜单
show_menu() {
    echo ""
    echo "请选择要下载的版本："
    echo "1) Minecraft 1.18.2 + Forge 40.2.4 (推荐)"
    echo "2) Minecraft 1.18.2 + Forge 40.2.10"
    echo "3) Minecraft 1.19.2 + Forge 43.3.0"
    echo "4) Minecraft 1.19.2 + Forge 43.3.13"
    echo "5) Minecraft 1.20.1 + Forge 47.2.0"
    echo "6) Minecraft 1.20.1 + Forge 47.3.0"
    echo "7) 下载所有常用版本"
    echo "8) 自定义版本"
    echo "0) 退出"
    echo ""
}

# 处理用户选择
handle_choice() {
    case $1 in
        1)
            download_forge "1.18.2" "40.2.4"
            ;;
        2)
            download_forge "1.18.2" "40.2.10"
            ;;
        3)
            download_forge "1.19.2" "43.3.0"
            ;;
        4)
            download_forge "1.19.2" "43.3.13"
            ;;
        5)
            download_forge "1.20.1" "47.2.0"
            ;;
        6)
            download_forge "1.20.1" "47.3.0"
            ;;
        7)
            echo "📦 下载所有常用版本..."
            download_forge "1.18.2" "40.2.4"
            download_forge "1.18.2" "40.2.10"
            download_forge "1.19.2" "43.3.0"
            download_forge "1.19.2" "43.3.13"
            download_forge "1.20.1" "47.2.0"
            download_forge "1.20.1" "47.3.0"
            ;;
        8)
            echo "请输入 Minecraft 版本 (例如: 1.18.2):"
            read mc_version
            echo "请输入 Forge 版本 (例如: 40.2.4):"
            read forge_version
            download_forge "$mc_version" "$forge_version"
            ;;
        0)
            echo "退出"
            exit 0
            ;;
        *)
            echo "❌ 无效选择，请重试"
            ;;
    esac
}

# 主循环
while true; do
    show_menu
    read -p "请输入选择 (0-8): " choice
    handle_choice "$choice"
    
    echo ""
    read -p "按 Enter 继续，或输入 'q' 退出: " continue
    if [ "$continue" = "q" ]; then
        break
    fi
done

echo ""
echo "📁 当前已下载的安装包："
ls -la *.jar 2>/dev/null || echo "无安装包文件"
echo ""
echo "💡 使用提示："
echo "1. 确保文件名格式正确：forge-{MC版本}-{Forge版本}-installer.jar"
echo "2. 在 docker-compose.yml 中设置对应的版本号"
echo "3. 运行 ./deploy.sh 开始部署"
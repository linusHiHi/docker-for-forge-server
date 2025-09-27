#!/bin/bash

# Minecraft Forge 服务器管理脚本
# 用于快速启动、停止和管理 Docker 化的 Minecraft 服务器

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "Minecraft Forge 服务器管理脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start     启动服务器"
    echo "  stop      停止服务器"
    echo "  restart   重启服务器"
    echo "  status    查看服务器状态"
    echo "  logs      实时查看服务器日志"
    echo "  shell     进入服务器容器"
    echo "  backup    备份世界存档"
    echo "  help      显示此帮助信息"
}

# 检查 Docker 和 Docker Compose
check_requirements() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装或不在 PATH 中"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose 未安装或不在 PATH 中"
        exit 1
    fi
}

# 启动服务器
start_server() {
    print_info "启动 Minecraft Forge 服务器..."
    
    # 确保数据目录存在
    mkdir -p "$SCRIPT_DIR/data/world"
    mkdir -p "$SCRIPT_DIR/data/modified_data"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" up -d
    else
        docker compose -f "$COMPOSE_FILE" up -d
    fi
    
    print_success "服务器已启动！"
    print_info "使用 '$0 logs' 查看实时日志"
    print_info "服务器地址: localhost:25564"
}

# 停止服务器
stop_server() {
    print_info "停止 Minecraft Forge 服务器..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" down
    else
        docker compose -f "$COMPOSE_FILE" down
    fi
    
    print_success "服务器已停止！"
}

# 重启服务器
restart_server() {
    print_info "重启 Minecraft Forge 服务器..."
    stop_server
    sleep 2
    start_server
}

# 查看状态
show_status() {
    print_info "服务器状态："
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" ps
    else
        docker compose -f "$COMPOSE_FILE" ps
    fi
}

# 查看日志
show_logs() {
    print_info "显示服务器日志（Ctrl+C 退出）："
    
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" logs -f
    else
        docker compose -f "$COMPOSE_FILE" logs -f
    fi
}

# 进入容器
enter_shell() {
    print_info "进入服务器容器..."
    docker exec -it planetary-server /bin/bash
}

# 备份世界
backup_world() {
    BACKUP_DIR="$SCRIPT_DIR/backups"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/world_backup_$TIMESTAMP.tar.gz"
    
    print_info "创建世界备份..."
    
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$SCRIPT_DIR/data/world" ]; then
        tar -czf "$BACKUP_FILE" -C "$SCRIPT_DIR/data" world
        print_success "备份已创建: $BACKUP_FILE"
    else
        print_warning "世界目录不存在，跳过备份"
    fi
}

# 主逻辑
main() {
    check_requirements
    
    case "${1:-help}" in
        start)
            start_server
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        shell)
            enter_shell
            ;;
        backup)
            backup_world
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
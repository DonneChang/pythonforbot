#!/bin/bash
set -e

# 设置默认值（如未设置）
: "${GIT_BRANCH:=main}"
: "${GIT_REMOTE:=https://github.com/DonneChang/tgbot-py.git}"

echo "=========================="
echo "当前 Python 版本: $(python --version 2>&1)"
echo "=========================="

echo "[Debug] 当前目录: $(pwd)"
echo "[Debug] SKIP_GIT=$SKIP_GIT"

# 拉取远程代码函数
gitpull() {
    echo "[Git] 拉取远程分支..."

    git fetch origin

    # 清理未追踪文件，防止 checkout 报错
    git clean -fd

    if ! git show-ref --verify --quiet refs/heads/"$GIT_BRANCH"; then
        echo "[Git] 创建本地分支 $GIT_BRANCH -> origin/$GIT_BRANCH"
        git checkout -b "$GIT_BRANCH" origin/"$GIT_BRANCH"
    else
        git checkout "$GIT_BRANCH"
        git reset --hard origin/"$GIT_BRANCH"
    fi

    git pull origin "$GIT_BRANCH"
}

# 初始化 Git 仓库并同步代码
if [ "$SKIP_GIT" != "true" ]; then
    if [ ! -d ".git" ]; then
        echo "[Git] 初始化本地仓库..."
        git config --global --add safe.directory /app
        git init
        git remote add origin "$GIT_REMOTE"
        git fetch origin
    fi
    echo "[Git] 开始同步代码..."
    gitpull
else
    echo "[Git] 跳过 Git 拉取（SKIP_GIT=true）"
fi

echo "[Pip] 正在更新 pip..."
pip install -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade pip

if [ "$INSTALL_SUPERVISOR" != "false" ]; then
    echo "[Pip] 安装 supervisor..."
    pip install supervisor -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade
else
    echo "[Pip] 跳过 supervisor 安装（INSTALL_SUPERVISOR=$INSTALL_SUPERVISOR）"
fi

if [ -f "requirements.txt" ]; then
    echo "[Pip] 安装 requirements.txt 中的依赖..."
    pip install -r requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade
fi

if [ "$INSTALL_SUPERVISOR" != "false" ]; then
    echo "[Supervisor] 启动 supervisord..."
    mkdir -p logs
    supervisord -c supervisord.conf -n
else
    echo "[Supervisor] supervisor 未启用，直接运行主程序"
    python main.py
fi
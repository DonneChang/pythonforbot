#!/bin/bash
set -e  # 脚本遇到错误时立即退出

echo "=========================="
echo "当前 Python 版本: $(python --version)"
echo "=========================="

gitpull() {
    echo "[Git] 拉取远程分支..."
    git reset --hard origin/"$GIT_BRANCH"
    git pull origin "$GIT_BRANCH"
}

if [ -n "$GIT_REMOTE" ]; then
    if [ -z "$GIT_BRANCH" ]; then
        echo "[Git] GIT_BRANCH 未设置，使用默认值 master"
        GIT_BRANCH="master"
    fi

    if [ ! -d ".git" ]; then
        echo "[Git] 初始化本地仓库..."
        git config --global --add safe.directory /app
        git init
        git remote add origin "$GIT_REMOTE"
        git fetch origin >/dev/null
    fi

    echo "[Git] 开始同步代码..."
    gitpull
fi

echo "[Pip] 正在更新 pip..."
pip install -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade pip >/dev/null

echo "[Pip] 正在安装 supervisor..."
pip install supervisor -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade >/dev/null

if [ -f "requirements.txt" ]; then
    echo "[Pip] 检测到 requirements.txt，开始安装依赖..."
    pip install -r requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade >/dev/null
fi

echo "[Supervisor] 启动 supervisord 服务..."
supervisord -c supervisord.conf -n

#!/bin/bash
set -e # 遇到错误立即退出

echo "=========================="
echo "当前 Python 版本: $(python --version)"
echo "=========================="

echo "[Debug] 当前目录: $(pwd)"
echo "[Debug] GIT_REMOTE=$GIT_REMOTE"
echo "[Debug] GIT_BRANCH=$GIT_BRANCH"
echo "[Debug] SKIP_GIT=$SKIP_GIT" 

gitpull() {
    echo "[Git] 拉取远程分支..."
    git reset --hard origin/"$GIT_BRANCH"
    git pull origin "$GIT_BRANCH"
}

if [ "$SKIP_GIT" != "true" ] && [ -n "$GIT_REMOTE" ]; then
    if [ -z "$GIT_BRANCH" ]; then
        echo "[Git] GIT_BRANCH 未设置，使用默认值 main"
        GIT_BRANCH="main"
    fi
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
    echo "[Git] 未执行 Git 拉取操作（可能未设置 GIT_REMOTE 或设置了 SKIP_GIT=true）"
fi
echo "[Pip] 正在更新 pip..."
pip install -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade pip

# 判断是否安装1 supervisor
if [ "$INSTALL_SUPERVISOR" != "false" ]; then
    echo "[Pip] 正在安装 supervisor..."
    pip install supervisor -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade
else
    echo "[Pip] 跳过 supervisor 安装（因为 INSTALL_SUPERVISOR=$INSTALL_SUPERVISOR）"
fi
if [ -f "requirements.txt" ]; then
    echo "[Pip] 检测到 requirements.txt，开始安装依赖..."
    pip install -r requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com --upgrade
fi
if [ "$INSTALL_SUPERVISOR" != "false" ]; then
    echo "[Supervisor] 启动 supervisord 服务..."
    supervisord -c supervisord.conf -n
else
    echo "supervisor 未安装不启动"
    python main.py
fi

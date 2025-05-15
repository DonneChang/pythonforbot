# 默认使用 Python 3.12，可通过构建时传参自定义
ARG PYTHON_VERSION=latest
FROM python:${PYTHON_VERSION}

# 设置环境变量（防止 tzdata 交互式提示）
ENV DEBIAN_FRONTEND=noninteractive

# 安装系统依赖：git、supervisor
RUN apt-get update && apt-get install -y \
    git \
    default-mysql-client \
    supervisor \
    wkhtmltopdf \
    xfonts-75dpi \
    xfonts-base \
    fonts-noto-cjk \
    fonts-wqy-zenhei \
    fonts-noto-color-emoji \ 
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    


# 设置工作目录
WORKDIR /tgbot_pyrogram

# 拷贝入口脚本并赋予执行权限
COPY docker-entrypoint.sh /tgbot_pyrogram/docker-entrypoint.sh
RUN chmod +x /tgbot_pyrogram/docker-entrypoint.sh

# 拷贝项目文件（你也可以改为 COPY . .）
# COPY requirements.txt .        # 可选
COPY supervisord.conf /tgbot_pyrogram/supervisord.conf

# 设置脚本为默认入口（推荐用 ENTRYPOINT）

ENTRYPOINT ["/tgbot_pyrogram/docker-entrypoint.sh"]
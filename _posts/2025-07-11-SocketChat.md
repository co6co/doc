---
layout: post
title:  Sanic框架

header-img: 
date:   2025-03-26 10:15:01
modify: 2025-03-26 10:15:01
categories: [开发,python]
tags: [sanic ]
---

# 1. 环境准备
```
# 启用EPEL存储库
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# 更新系统
sudo dnf update -y

# 安装必要的依赖
sudo dnf install -y curl wget gnupg2 gcc-c++ make python3

# 安装Node.js 22.x
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo dnf install -y nodejs

# 安装Yarn
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo dnf install -y yarn
```

# 2. 安装并配置 MongoDB 6.0
```
# 添加MongoDB官方源
sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

# 安装MongoDB
sudo dnf install -y mongodb-org

# 启动并设置MongoDB开机自启
sudo systemctl start mongod
sudo systemctl enable mongod

# 验证MongoDB状态
sudo systemctl status mongod
```

# 3.下载并安装 Rocket.Chat
```
# 创建Rocket.Chat目录
sudo mkdir -p /opt/Rocket.Chat
sudo chown $USER:$USER /opt/Rocket.Chat

# 下载Rocket.Chat-7.7.2.tar.gz
cd /opt/Rocket.Chat
wget https://releases.rocket.chat/7.7.2/download -O rocket.chat.tgz

# 解压文件
tar zxvf rocket.chat.tgz
cd bundle/programs/server

# 安装依赖
yarn install --production

# 配置环境变量
echo 'export RC_ENVIRONMENT=staging' >> ~/.bashrc
echo 'export MONGO_URL=mongodb://localhost:27017/rocketchat' >> ~/.bashrc
echo 'export ROOT_URL=http://localhost:3000' >> ~/.bashrc
echo 'export PORT=3000' >> ~/.bashrc
source ~/.bashrc
```

# 4. 创建系统服务
```
# 创建服务文件
sudo tee /etc/systemd/system/rocketchat.service <<EOF
[Unit]
Description=Rocket.Chat Server
After=network.target mongod.service

[Service]
ExecStart=/usr/bin/node /opt/Rocket.Chat/bundle/main.js
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=rocketchat
Group=rocketchat
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat
Environment=ROOT_URL=http://localhost:3000
Environment=PORT=3000
Environment=RC_ENVIRONMENT=staging
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 创建Rocket.Chat用户
sudo useradd -M -s /bin/false rocketchat
sudo chown -R rocketchat:rocketchat /opt/Rocket.Chat

# 启动服务并设置开机自启
sudo systemctl daemon-reload
sudo systemctl start rocketchat
sudo systemctl enable rocketchat

# 检查服务状态
sudo systemctl status rocketchat
```

# 5.配置防火墙
```
# 开放Rocket.Chat端口
sudo firewall-cmd --permanent --add-port=3000/tcp

# 如果需要配置HTTPS，还需开放443端口
# sudo firewall-cmd --permanent --add-port=443/tcp

# 重载防火墙规则
sudo firewall-cmd --reload
```

# 6. 配置反向代理（可选）
```
# 安装Nginx
sudo dnf install -y nginx

# 创建Nginx配置文件
sudo tee /etc/nginx/conf.d/rocketchat.conf <<EOF
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forward-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forward-Proto http;
        proxy_set_header X-Nginx-Proxy true;
        proxy_redirect off;
    }
}
EOF

# 验证配置并重启Nginx
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# 安装Certbot获取SSL证书（可选）
sudo dnf install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com


# 调试
```
# 停止自动重启的服务
sudo systemctl stop rocketchat

# 以调试模式运行（前台输出日志）
cd /opt/Rocket.Chat/bundle
MONGO_URL=mongodb://localhost:27017/rocketchat \
ROOT_URL=http://localhost:3000 \
PORT=3000 \
node main.js
```
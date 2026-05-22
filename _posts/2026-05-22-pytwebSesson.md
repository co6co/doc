---
layout: post
title: Sanic及aiohttp 常用 session

header-img:
date: 2026-05-22 10:15:01
modify: 2026-05-08 08:50:01
categories: [python]
tags: [session]
---

# 1. Sanic 官方没有内置 session
## 1.0 方案
主流稳定方案是用 
- sanic-session（服务端 session，支持内存 / Redis/Memcache/Mongo），
-  轻量CookieSession（客户端）

## 1.1. sanic-session 内存版（最简，开发用）.

特点：
- Session(app) 自动注册前后置中间件，无需手动挂
- 会话数据存在服务端内存，通过 session-id cookie 关联客户端
- 访问：request.ctx.session（dict 用法，增删改查）

```
pip install sanic_session


from sanic import Sanic, response
from sanic_session import Session  # 内存接口

app = Sanic("session_demo")

# 初始化 Session（挂到 app，自动注册中间件）
Session(app)

@app.route("/login")
async def login(request):
    # 模拟登录：拿到 user_key
    user_key = "user_12345"
    # 存入 session（request.ctx.session 是 dict-like）
    request.ctx.session["user_key"] = user_key
    return response.text(f"登录成功，user_key: {user_key}")

@app.route("/get_user")
async def get_user(request):
    # 读取 session
    user_key = request.ctx.session.get("user_key")
    if user_key:
        return response.text(f"当前用户 key: {user_key}")
    else:
        return response.text("未登录", status=401)

@app.route("/logout")
async def logout(request):
    # 清空 session
    request.ctx.session.clear()
    return response.text("已登出")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
```
# 1.2. sanic-session Redis 版
```
pip install sanic_session[aioredis]  # 含 aioredis
from sanic import Sanic, response
from sanic_session import Session, RedisSessionInterface
import aioredis

app = Sanic("redis_session")

# 1. 创建 Redis 连接池
async def get_redis():
    return await aioredis.from_url("redis://localhost:6379/0")

# 2. 初始化 Redis Session 接口
session_interface = RedisSessionInterface(
    app,
    redis=get_redis,  # 连接池 getter
    prefix="session:",  # Redis key 前缀
    expiry=86400  # 会话过期时间（1天，秒）
)
Session(app, interface=session_interface)

# 路由同内存版（完全不用改）
@app.route("/login")
async def login(request):
    user_key = "user_67890"
    request.ctx.session["user_key"] = user_key
    return response.text(f"Redis 登录成功，user_key: {user_key}")

@app.route("/get_user")
async def get_user(request):
    user_key = request.ctx.session.get("user_key")
    return response.text(user_key or "未登录")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
	
# 常见配置
RedisSessionInterface(
    app,
    redis=get_redis,
    cookie_name="session_id",  # cookie 名
    httponly=True,  # cookie 仅 HTTP 访问，防 XSS
    samesite="lax",  # 防 CSRF
    expiry=3600*24*7,  # 7天过期
    prefix="myapp:session:"
)
```

# 1.3. Sanic-CookieSession（客户端，轻量）
不要存敏感密码，内容是base64 编码 + 签名，可解码

```
pip install Sanic-CookieSession

from sanic import Sanic, response
import sanic_cookiesession

app = Sanic("cookie_session")
app.config["SESSION_COOKIE_SECRET_KEY"] = "your-secret-key-here"  # 必须，签名用

sanic_cookiesession.setup(app)

@app.route("/login")
async def login(request):
    request.ctx.session["user_key"] = "user_cookie_123"
    return response.text("Cookie 登录成功")

@app.route("/get_user")
async def get_user(request):
    return response.text(request.ctx.session.get("user_key", "未登录"))

if __name__ == "__main__":
    app.run(port=8000)
	
```


# 2. aiohttp
aiohttp：app.middlewares.appendleft(mw) 手动挂 session 中间件

## 2.1 纯手写
```
from aiohttp import web

app = web.Application()
app['sessions'] = {}  # ✅ 直接把 Session 字典挂在 app 上

async def index(request):
    # 用 session_id 区分用户
    session_id = request.cookies.get('sid', 'default')
    session = app['sessions'].setdefault(session_id, {})
    
    # 存用户 key
    session['user_key'] = 'user_123'
    
    return web.json_response(session)

app.add_routes([web.get('/', index)])
web.run_app(app) 
```

## 2.2 官方方案

```
pip install aiohttp aiohttp_session

from aiohttp import web
from aiohttp_session import setup, get_session, session_middleware
from aiohttp_session.cookie_storage import EncryptedCookieStorage

# 生成密钥（生产环境自己写一个固定的）
SECRET_KEY = b'your-secret-key-keep-it-safe-1234567890'

# --------------------------
# 路由处理
# --------------------------
async def login_handler(request):
    # ✅ 获取 session
    session = await get_session(request)
    
    # ✅ 把用户 key 存入 session（你要的功能）
    session['user_key'] = 'user_10086_abc'
    
    return web.json_response({
        'msg': '登录成功',
        'user_key': session['user_key']
    })

async def info_handler(request):
    # ✅ 获取 session
    session = await get_session(request)
    
    # ✅ 读取用户 key
    user_key = session.get('user_key', '未登录')
    
    return web.json_response({
        'user_key': user_key
    })

async def logout_handler(request):
    session = await get_session(request)
    session.invalidate()  # 清除 session
    return web.json_response({'msg': '退出登录'})

# --------------------------
# 创建 app + 挂载 Session
# --------------------------
def main():
    app = web.Application()

    # ==============================================
    # ✅ 关键：给 app 挂载 Session 中间件
    # ==============================================
    setup(app, EncryptedCookieStorage(SECRET_KEY)) #通过中间件全局生效

    # 路由
    app.add_routes([
        web.get('/login', login_handler),
        web.get('/info', info_handler),
        web.get('/logout', logout_handler),
    ])

    web.run_app(app, port=8080)

if __name__ == '__main__':
    main()
	
	
	
#存
session = await get_session(request)
session['user_key'] = 'your-user-unique-key'

#取
session = await get_session(request)
user_key = session.get('user_key')
#清
session.invalidate()
```
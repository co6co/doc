---
layout: post
title: PYthon进程线程
date:       2023-7-27 15:02:01
---

# 1. 进程
# 2. 线程
## 2.1 简介
与创建进程不同，创建进程代码不需要再 `__main__`方法下[新线程不需要复制代码]
```
def run(name:str,s:int=30)->None:    
    log.info(f"{name}")
    time.sleep(s)
    log.info(f"{name} .{s}s exit ")
    
def main():
    '''
	总结线程：
    join: 需要等待线程结束才继续
    setDaemo: 将线程设为守护线程[主线程退出, 守护线程也退出]
    run: 可理解为 start 和 join 的功能合一
    '''
    t=threading.Thread(target=run,args=("线程1",5,))
    t.setDaemon(True) # 设置了守护父进程退出 守护线程也退出
    #t.run()# 卡住，线程不完程序不走
    t.start()
    #t.join() # 卡住 等待子线程执行完，
             #不存在该语句，子线程仍旧执行，只是
    t2=threading.Thread(target=run,args=("线程2",10,))
    t2.start()
    t2.join() # 主线程等待T2 执行完就退出
    #t.join()

 
if __name__ == "__main__":
    log.info("main Thread.")
    main()
    log.info("main exit")
```
---
layout: post
title: SELinux
subtitle:
date:       2021-09-10 13:43:44
categories: [Linux]
tags: [Linux,SELinux]
---


# 1.安全增强型 Linux（SELinux）
采用安全架构的 Linux® 系统，
它能够让管理员更好地管控哪些人可以访问系统。
它最初是作为 Linux 内核的一系列补丁，由美国国家安全局（NSA）利用 Linux 安全模块（LSM）开发而成。

## 1.1 工作原理
SELinux 定义了每个人对系统上的应用、进程和文件的访问权限。它利用安全策略来强制执行策略所允许的访问。

当应用或进程（称为主体）发出访问对象（如文件）的请求时，SELinux 会检查访问`向量缓存（AVC）`，其中`缓存`有主体和对象的访问权限。

如果 SELinux 无法根据缓存对权限做出访问决定，它会将请求发送到`安全服务器`。安全服务器随即检查应用或进程和文件的安全环境，确认其是否匹配 SELinux 策略数据库的安全环境。之后便根据检查授予权限或拒绝。

如果被拒绝，`/var/log.messages` 中将会显示消息`"avc: denied"`。

## 1.2 配置SELinux
可通过多种方式来配置 SELinux，以保护您的系统。最常见的是`目标策略`或`多级安全防护（MLS）`。 
目标策略为默认选项，它涵盖了多种流程、任务和服务。MLS 则极为复杂，通常只有政府机构才会使用。

您可以查看 `/etc/sysconfig/selinux` 文件，以判断系统所采用的配置方式。
该文件中有一部分会显示 SELinux 是处于允许模式、强制模式还是处于禁用状态，以及要加载哪个策略。
```
[root@localhost ~]# cat /etc/selinux/config 

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted 

```

## 1.3 标签和类型强制访问控制
是 SELinux 中最为重要的两个概念
1. 作为标签系统运行:
所有文件、进程和端口都具有与之关联的 `SELinux 标签`。标签可以按照逻辑将目标组合分类。在启动过程中，`内核`负责管理标签。

标签的格式: `user:role:type:level`（level 为可选项）。
User、role 和 level 用于类似 MLS 的更高级的 SELinux 实施中。标签类型对于目标策略而言最为重要。

2. 类型强制访问控制
强制执行系统中定义的策略。类型强制访问控制是 SELinux 策略的一部分，它定义了特定类型的进程能否访问标记为特定类型的文件。

## 1.4 启用SELinux
可以通过编辑 /etc/selinux/config 并设置 `SELINUX=permissive` 来启用 SElinux,由于 SELinux 当前尚未启用，
因此`最好不要将其设为立即强制执行`，因为此时系统可能会出现`误标记`的事件，它会妨碍系统的正常启动。

可以在`根目录`中创建名为 `.autorelabel` 的空文件，然后重新启动，
以此来`强制系统自动为整个文件系统重新标记SELinux`。
如果系统中错误过多，应在允许模式下重新启动，以确保启动成功。重新标记所有内容后，
利用 /etc/selinux/config 将 SELinux 设置为强制模式并重新启动，或运行 setenforce 1。


# 2. 自主访问控制（DAC）与强制访问控制（MAC）
Linux 和 UNIX 系统都采用 DAC。SELinux 是 Linux 采用 MAC 机制的一个示例
 1. DAC，文件和进程都有相应的所有者。您可以让用户拥有某个文件，让群组拥有某个文件，或让其他人（可以是其他任何人）拥有某个文件。用户可以更改自己文件的权限。
用户对 DAC 系统拥有完全访问控制权。如果您拥有根访问权限，则可以访问其他任何用户的文件，或在系统上执行任何操作

2. MAC 系统上，访问权限有相应的管理设置策略。即使主目录上的 DAC 设置发生更改，
SELinux 策略也会阻止其他用户或进程访问目录，从而保证系统的安全。

# 3. SELinux 发生错误
当 SELinux 发生错误，您需要及时采取对策。常见问题不外乎以下 4 种：

标签错误。如果标签不正确，您可以使用工具来修复标签。

策略需要修复。可能是指您需要将所做的更改通知给 SELinux，或是可能需要调整策略。您可以利用布尔值或策略模块对其进行修复。

策略中存在错误。可能是策略中存在需要消除的错误。

系统已损坏。尽管 SELinux 在很多情况下可以保护您的系统，但系统仍存在受损的可能。如果您怀疑是这种情况，请立即采取相应的措施。


# 4. 相关命令
## 4.1.布尔值

是 SELinux 中功能的开/关设置。开/关 SELinux 功能的设置有数百种，而且许多设置已预定义。您可以通过运行 `getsebool -a`，找出系统中已设置的布尔值。

`getsebool | setsebool semanage`
## 4.2 命令
`setenforce 0/1`
```
setsebool -P tmpDir on # -P表示永久打开

[root@localhost ~]# getsebool -a |grep mysql
mysql_connect_any --> off
selinuxuser_mysql_connect_enabled --> off
[root@localhost ~]# setsebool -P mysql_connect_any on
[root@localhost ~]# getsebool -a |grep mysql
mysql_connect_any --> on
selinuxuser_mysql_connect_enabled --> off



[root@localhost ~]# semanage port -l | grep http 
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989

[root@localhost ~]# semanage port -a -t http_port_t -p tcp 8090
[root@localhost ~]# semanage port -a -t http_port_t -p tcp 8091
[root@localhost ~]# semanage port -l | grep http 
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      8091, 8090, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```

## 4.3 修改文件的安全上下文
```
ls -Z  # 查看 public_content_t
semanage fcontext -l
chcon -t public_context_t file1.txt  # 修改文件file1.txt 的安全上下文
-rw-r--r--. root root unconfined_u:object_r:public_content_t:s0 file1.txt

```
## 4.4 修改目录的安全上下文
```
#临时的：
 chcon -t public_content_t /tmpDir -R      						#	-R表示递归
#永久：
 semanage fcontext -a -t public_content_t '/tmpDir(/.*)?'		#   -a表示增加
 
 #递归刷新并显示刷新过程
 restorecon -FvvR /tmpDir 
```


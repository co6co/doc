---
layout: post
title: numpy 安装异常

header-img:
date: 2026-05-22 10:15:01
modify: 2026-05-08 08:50:01
categories: [python]
tags: [numpy]
---

# 1.  安装异常
```
  error: subprocess-exited-with-error

  × Preparing metadata (pyproject.toml) did not run successfully.
  │ exit code: 1
  ╰─> [21 lines of output]
      + C:\Users\Administrator\envs\XXX\Scripts\python.exe C:\Users\Administrator\AppData\Local\Temp\pip-install-vw1r0wgd\numpy_ddb0aa0053f249f8a8072b64ca799551\vendored-meson\meson\meson.py setup C:\Users\Administrator\AppData\Local\Temp\pip-install-vw1r0wgd\numpy_ddb0aa0053f249f8a8072b64ca799551 C:\Users\Administrator\AppData\Local\Temp\pip-install-vw1r0wgd\numpy_ddb0aa0053f249f8a8072b64ca799551\.mesonpy-25uy5fdt\build -Dbuildtype=release 
-Db_ndebug=if-release -Db_vscrt=md --native-file=C:\Users\Administrator\AppData\Local\Temp\pip-install-vw1r0wgd\numpy_ddb0aa0053f249f8a8072b64ca799551\.mesonpy-25uy5fdt\build\meson-python-native-file.ini
      The Meson build system
      Version: 1.2.99
      Source dir: C:\Users\Administrator\AppData\Local\Temp\pip-install-vw1r0wgd\numpy_ddb0aa0053f249f8a8072b64ca799551
      Build dir: C:\Users\Administrator\AppData\Local\Temp\pip-install-vw1r0wgd\numpy_ddb0aa0053f249f8a8072b64ca799551\.mesonpy-25uy5fdt\build
      Build type: native build
      Project name: NumPy
      Project version: 1.26.2
      WARNING: Failed to activate VS environment: Could not find C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe
     
      ..\..\meson.build:1:0: ERROR: Unknown compiler(s): [['icl'], ['cl'], ['cc'], ['gcc'], ['clang'], ['clang-cl'], ['pgcc']]
      The following exception(s) were encountered:
      Running `icl ""` gave "[WinError 2] 系统找不到指定的文件。"
      Running `cl /?` gave "[WinError 2] 系统找不到指定的文件。"
      Running `cc --version` gave "[WinError 2] 系统找不到指定的文件。"
      Running `gcc --version` gave "[WinError 2] 系统找不到指定的文件。"
      Running `clang --version` gave "[WinError 2] 系统找不到指定的文件。"
      Running `clang-cl /?` gave "[WinError 2] 系统找不到指定的文件。"
      Running `pgcc --version` gave "[WinError 2] 系统找不到指定的文件。"
     
      A full log can be found at C:\Users\Administrator\AppData\Local\Temp\pip-install-vw1r0wgd\numpy_ddb0aa0053f249f8a8072b64ca799551\.mesonpy-25uy5fdt\build\meson-logs\meson-log.txt
      [end of output]

  note: This error originates from a subprocess, and is likely not a problem with pip.
error: metadata-generation-failed

× Encountered error while generating package metadata.
╰─> numpy

note: This is an issue with the package mentioned above, not pip.
```
## 因缺少C++编译环境
安装 安装微软官方的 Microsoft C++ Build Tools（轻量版）
[vs_BuildTools.exe](ttps://aka.ms/vs/17/release/vs_BuildTools.exe) 只需勾选 **Desktop development with C++（使用 C++ 的桌面开发）**
---
layout: post
title: ffmpeg常用命令
subtitle:
date:       2022-03-08 10:44:37
categories: [ffmpeg]
tags: [ffmpeg]
---

# 在保持视频质量的前提下大幅压缩体积
```
# 压缩文件
ffmpeg -i input.mp4 -c:v libx265 -preset medium -crf 28 -c:a aac -b:a 128k output.mp4

/***
*  libx265，相较于 H.264，它的压缩效率提升了约 30%
*  -crf 28 代表质量控制参数，取值范围是 0 - 51，28 属于比较平衡的设置
*  音频编码采用 AAC，码率设为 128k，能满足一般的听觉需求
***/
```

# 针对网络优化
```
ffmpeg -i input.mp4 -c:v libx264 -preset slow -crf 23 -tune film -movflags +faststart -c:a aac -b:a 192k output.mp4

/***
*	libx264，它的兼容性更强，并且支持 -tune film 这种针对电影内容的优化
*	-crf 23  是质量和体积的平衡值，数值越小，视频质量越高
*	-movflags +faststart 可让视频在网络播放时实现快速加载。
***/
```

# 按指定大小进行压缩
```
ffmpeg -i input.mp4 -fs 50M -c:v libx264 -preset medium -c:a aac output.mp4

/***
*	-fs 50M 用于限制输出文件的大小为 50MB。
*	自动调整视频的码率来达到设定的文件大小
***/
```

# 
```
ffmpeg -i input.mp4 -preset veryfast \
  -map 0:v -map 0:a -s:v:0 1280x720 -c:v:0 libx264 -crf:0 23 \
  -map 0:v -map 0:a -s:v:1 854x480 -c:v:1 libx264 -crf:1 25 \
  -map 0:v -map 0:a -s:v:2 640x360 -c:v:2 libx264 -crf:2 27 \
  -c:a aac -b:a 128k -f hls -hls_list_size 0 -hls_segment_type mpegts output.m3u8
  
  /***
  * 视频编码器（-c:v）：推荐使用 libx265（压缩率更高）或者 libx264（兼容性更好）
  * 质量控制（-crf）：H.264 建议取值在 18 - 28 之间，H.265 可以比 H.264 高 2 - 3
  *	编码速度（-preset）：有 ultrafast、superfast、veryfast、medium、slow、veryslow 这些选项可供选择。编码速度越慢，压缩效率越高。
  *	音频编码（-c:a）：优先选择 AAC 或者 Opus
  ***/
```

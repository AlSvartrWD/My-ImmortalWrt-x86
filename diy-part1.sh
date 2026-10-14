#!/bin/bash
# 将 ImmortalWrt 官方 feeds 源替换为清华大学镜像（国内兜底）
sed -i 's#https://github.com/immortalwrt#https://mirrors.tuna.tsinghua.edu.cn/immortalwrt#g' feeds.conf.default

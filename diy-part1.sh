#!/bin/bash
# 将 ImmortalWrt 官方 feeds 源替换为清华大学镜像（国内兜底）
sed -i 's#https://github.com/immortalwrt#https://mirrors.tuna.tsinghua.edu.cn/immortalwrt#g' feeds.conf.default

# 添加 OpenClash 源
echo 'src-git openclash https://github.com/vernesong/OpenClash' >>feeds.conf.default

# 添加 kenzok8 常用插件源（包含 UPnP 等）
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

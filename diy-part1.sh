#!/bin/bash
# 添加 OpenClash 源
echo 'src-git openclash https://github.com/vernesong/OpenClash' >>feeds.conf.default
echo 'src-git uugamebooster https://github.com/kenzok8/openwrt-packages.git;openwrt-24.10' >>feeds.conf.default

# 添加 kenzok8 常用插件源（包含 UPnP）
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

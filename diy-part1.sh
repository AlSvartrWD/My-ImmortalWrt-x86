#!/bin/bash
#
# 在 feeds update -a 之前执行：添加第三方 feed
# OpenClash 无需额外 feed —— ImmortalWrt 官方 luci 源已自带 luci-app-openclash
#

# UU加速器（luci-app-uugamebooster）：25.12+ 用 master 分支
echo 'src-git fengqipackages https://github.com/fengqi/immortalwrt-packages.git' >> feeds.conf.default

exit 0

#!/bin/bash
#
# 在加载 .config 之后执行
# 把 luci-light 集合锁定的默认主题从 bootstrap 换成 material
#
sed -i 's/luci-theme-bootstrap/luci-theme-material/g' feeds/luci/collections/luci-light/Makefile

exit 0

#!/bin/bash
#
# 在加载 .config 之后执行
#

# 1) 默认主题：bootstrap -> material
sed -i 's/luci-theme-bootstrap/luci-theme-material/g' feeds/luci/collections/luci-light/Makefile

# 2) 修复 UU 加速器（网易会删除旧版本并更换下载主机，导致云编译下载失败）
UU_MK="feeds/fengqipackages/uugamebooster/Makefile"

if [ -f "$UU_MK" ]; then
    echo "==> Patching UU Game Booster package"

    UU_API='http://router.uu.163.com/api/plugin?type=openwrt-x86_64'
    UU_JSON="$(curl -s --max-time 20 -H 'Accept:text/plain' "$UU_API" || true)"

    # 当前版本号
    UU_VER="$(printf '%s' "$UU_JSON" | grep -o 'openwrt-x86_64/v[0-9.]*' | head -n1 | sed 's#.*/v##')"
    # 网易官方直链
    UU_URL="$(printf '%s' "$UU_JSON" | grep -o '"url":"[^"]*"' | head -n1 | cut -d'"' -f4)"

    [ -n "$UU_VER" ] || UU_VER='14.9.4'
    [ -n "$UU_URL" ] || UU_URL="https://uurouter.gdl.netease.com/uuplugin/openwrt-x86_64/v$UU_VER/uu.tar.gz"
    echo "==> UU version: $UU_VER"

    # 修正版本号
    sed -i "s#^PKG_VERSION:=.*#PKG_VERSION:=$UU_VER#" "$UU_MK"
    # 修正下载主机（旧: uu.gdl.netease.com）
    sed -i 's#uu.gdl.netease.com#uurouter.gdl.netease.com#g' "$UU_MK"

    # 预先下载，并把真实 sha256 写回 Makefile
    mkdir -p dl
    UU_FILE="dl/uugamebooster-$UU_VER-x86_64.tar.gz"
    if curl -L --retry 3 --max-time 180 -o "$UU_FILE" "$UU_URL"; then
        UU_SHA="$(sha256sum "$UU_FILE" | awk '{print $1}')"
        echo "==> UU sha256: $UU_SHA"
        sed -i "s#PKG_HASH:=.*#PKG_HASH:=$UU_SHA#" "$UU_MK"
    else
        echo "==> UU download failed, fallback to PKG_HASH:=skip"
        sed -i 's#PKG_HASH:=.*#PKG_HASH:=skip#' "$UU_MK"
    fi

    grep -E 'PKG_VERSION|PKG_HASH|PKG_SOURCE_URL' "$UU_MK" | head -n 8
fi

exit 0

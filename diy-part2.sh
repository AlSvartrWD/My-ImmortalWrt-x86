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

# 3) OpenClash：换用上游 vernesong 的 0.48.002（ImmortalWrt 各分支自带 0.47.156，太旧）
#    固定 commit，保证构建可复现；失败时不中断构建，退回 feed 自带版本。
OPENCLASH_PIN="e553e82e01c697aefbe1555261a503f425e00ccd"
if [ -d feeds/luci/applications/luci-app-openclash ]; then
    echo "==> 移除 feed 自带 luci-app-openclash (0.47.156)"
    rm -rf feeds/luci/applications/luci-app-openclash
fi
if [ ! -d package/luci-app-openclash ]; then
    echo "==> 拉取上游 OpenClash 并固定到 $OPENCLASH_PIN"
    if git clone --quiet https://github.com/vernesong/OpenClash.git "$GITHUB_WORKSPACE/oc-upstream" 2>/dev/null \
       && git -C "$GITHUB_WORKSPACE/oc-upstream" checkout --quiet "$OPENCLASH_PIN" 2>/dev/null; then
        cp -a "$GITHUB_WORKSPACE/oc-upstream/luci-app-openclash" package/luci-app-openclash
        echo "==> 上游版本：$(grep -E '^PKG_VERSION' package/luci-app-openclash/Makefile)"
    else
        echo "==> !! 上游拉取失败，回退到 feed 版本（0.47.156），请检查"
    fi
    rm -rf "$GITHUB_WORKSPACE/oc-upstream"
fi

# 4) 自定义 LuCI 包：TCP 拥塞控制开关页（luci-app-tcpcc）
#    包本体在仓库根目录 luci-app-tcpcc/，这里拷进 openwrt/package/ 供 defconfig 扫描。
#    .config 里 CONFIG_PACKAGE_luci-app-tcpcc=y 依赖它存在；拷失败就让构建直接失败，
#    否则会静默得到一个"没有开关页"的固件。
if [ -d "$GITHUB_WORKSPACE/luci-app-tcpcc" ]; then
    echo "==> 安装自定义包 luci-app-tcpcc"
    rm -rf "$PWD/package/luci-app-tcpcc"
    cp -a "$GITHUB_WORKSPACE/luci-app-tcpcc" "$PWD/package/luci-app-tcpcc"
    ls -l "$PWD/package/luci-app-tcpcc"
else
    echo "==> !! 仓库里找不到 luci-app-tcpcc，中止（避免编出没有开关页的固件）"
    exit 1
fi

exit 0

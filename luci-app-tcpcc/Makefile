#
# LuCI app: TCP 拥塞控制（bbr / cubic 切换 + 默认 qdisc）
#
# 依赖 kmod-tcp-bbr 提供 tcp_bbr.ko，kmod-sched 提供 sch_fq.ko。
# 开关页：网络 -> TCP 拥塞控制
#
include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI app for TCP congestion control (BBR/cubic) and default qdisc
LUCI_DESCRIPTION:=Switch TCP congestion control algorithm and default qdisc at runtime, persisted in /etc/config/tcpcc
LUCI_DEPENDS:=+kmod-tcp-bbr +kmod-sched
LUCI_PKGARCH:=all
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

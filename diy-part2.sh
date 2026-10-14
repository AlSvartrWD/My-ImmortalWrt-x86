#!/bin/bash
# 1. 修改默认 LAN IP 为 10.10.10.2
sed -i 's/192.168.1.1/10.10.10.2/g' package/base-files/files/bin/config_generate

# 2. 强制在配置中选中 Material 主题（防止 .config 漏选）
echo "CONFIG_PACKAGE_luci-theme-material=y" >> .config

# 3. 创建首次启动脚本目录
mkdir -p files/etc/uci-defaults

# 4. 预置旁路由完整配置
cat << 'EOF' > files/etc/uci-defaults/99-custom
#!/bin/sh
# 设置旁路由网关和 DNS
uci set network.lan.gateway='10.10.10.1'
uci set network.lan.dns='114.114.114.114 223.5.5.5'

# 关闭 DHCP
uci set dhcp.lan.ignore='1'

# 关闭 IPv6
uci -q delete network.lan.ip6assign
uci -q delete network.globals.ula_prefix
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci -q delete dhcp.lan.ndp
uci -q delete dhcp.lan.ra_flags

# 设置 root 密码为 123456
echo -e "123456\n123456" | passwd root

# 启用 SNMP 服务（供 iKuai 跨三层识别设备 MAC）
service snmpd enable

# 旁路由防火墙优化
uci set firewall.@defaults[0].syn_flood='0'
uci set firewall.@zone[1].masq='0'
uci set firewall.@zone[1].mtu_fix='1'

# 设置默认主题为 Material
uci set luci.main.mediaurlbase='/luci-static/material'

uci commit
exit 0
EOF

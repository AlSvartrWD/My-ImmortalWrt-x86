local sys = require("luci.sys")

local function read_proc(path)
	local f = io.open(path, "r")
	if not f then
		return ""
	end
	local line = f:read("*l") or ""
	f:close()
	return (line:gsub("%s+$", ""))
end

local function available_cc()
	local list = {}
	for name in read_proc("/proc/sys/net/ipv4/tcp_available_congestion_control"):gmatch("%S+") do
		list[#list + 1] = name
	end
	return list
end

m = Map("tcpcc", "TCP 拥塞控制",
	"选择 TCP 拥塞控制算法与默认队列调度（qdisc）。保存并应用后立即生效；" ..
	"配置写入 /etc/config/tcpcc，重启后由 /etc/init.d/tcpcc 自动恢复。")

s = m:section(NamedSection, "main", "tcpcc", "设置")
s.addremove = false
s.anonymous = false

cc = s:option(ListValue, "cc", "拥塞控制算法")
cc.description = "列表来自 /proc/sys/net/ipv4/tcp_available_congestion_control，内核没编进来的算法不会出现。"
for _, name in ipairs(available_cc()) do
	cc:value(name, name)
end

qd = s:option(ListValue, "qdisc", "默认队列调度")
qd.description = "BBR 建议配 fq（fq 由 kmod-sched 提供）。fq_codel 是系统默认。"
for _, name in ipairs({"fq", "fq_codel", "cake", "pfifo_fast"}) do
	qd:value(name, name)
end

st = m:section(SimpleSection, nil, "运行状态")
d = st:option(DummyValue, "_state", nil)
d.rawhtml = true

function d.cfgvalue()
	return string.format(
		"当前生效：<b>%s</b>，qdisc <b>%s</b><br />可用算法：%s",
		read_proc("/proc/sys/net/ipv4/tcp_congestion_control"),
		read_proc("/proc/sys/net/core/default_qdisc"),
		table.concat(available_cc(), ", ")
	)
end

function m.on_after_commit()
	sys.call("/etc/init.d/tcpcc restart >/dev/null 2>&1")
end

return m

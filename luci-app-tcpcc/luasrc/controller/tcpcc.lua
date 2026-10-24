local translate = require("luci.i18n").translate

module("luci.controller.tcpcc", package.seeall)

function index()
	entry({"admin", "network", "tcpcc"}, cbi("tcpcc"), translate("TCP 拥塞控制"), 60)
end

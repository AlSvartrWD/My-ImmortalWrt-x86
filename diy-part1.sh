#!/bin/bash
# 删除引发报错的 routing 和 telephony 源
sed -i '/src-git routing/d' feeds.conf.default
sed -i '/src-git telephony/d' feeds.conf.default

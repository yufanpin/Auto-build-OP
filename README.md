# 通用编译模板
主要是openwrt-builder.yml启动编译，支持手动，支持自动
当update-checker.yml检测到上游openwrt源码发生更新时，自动启动openwrt-builder.yml开始编译openwrt
update-checker.yml支持多个workflow启动编译，详细信息可以看update-checker.yml的源码

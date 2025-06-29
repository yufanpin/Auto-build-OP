# 通用编译模板
```
你的 GitHub 仓库结构：
├── .github/
│   └── workflows/
│       └── openwrt-builder.yml           <- 编译openwrt主程序
│       └── update-checker.yml            <- 检测上游源码是否更新
├── configs/
│   └── recs07.config          <- 编译配置文件           
├── diy-script.sh              <- 自定义补丁/设置脚本    
└── README.md

主要是openwrt-builder.yml启动编译，支持手动，支持自动
当update-checker.yml检测到上游openwrt源码发生更新时，自动启动openwrt-builder.yml开始编译openwrt
update-checker.yml支持多个workflow启动编译，详细信息可以看update-checker.yml的源码
```

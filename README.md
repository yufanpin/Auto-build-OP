# Immortalwrt-OpenWRT-CI
云编译Immortalwrt固件

本项目参考了[VIKINGYFY](https://github.com/VIKINGYFY/OpenWRT-CI) 和 [ftkey](https://github.com/ftkey/ER1-WRT-CI) 的云编译项目。

源码使用VIKINGYFY的Immortalwrt高通版：
https://github.com/VIKINGYFY/immortalwrt.git

# 固件简要说明：

固件只针对QUALCOMMAX系列的JDCloud RE-CS-07(京东云太乙有线路由器)

分APK和IPK两种包管理

尽可能集成少量的插件，一些流行插件只做编译而不集成进固件

编译时生成的所有插件打包供下载

# 目录简要说明：

workflows——自定义CI配置

Scripts——自定义脚本

Config——自定义配置

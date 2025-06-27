#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

#添加编译日期标识
WRT_DATE_SHORT=$(echo $WRT_DATE | sed 's/\([0-9][0-9]\)\.\([0-9][0-9]\)\.\([0-9][0-9]\)-.*/20\1.\2.\3/')
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Build by bluehj $WRT_DATE_SHORT')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

#修改Argon主题footer
ARGON_HTM_FILES=$(find . -path "*/luci-theme-argon/*" -name "*.htm" -type f)
if [ -n "$ARGON_HTM_FILES" ]; then
    for HTM_FILE in $ARGON_HTM_FILES; do
        # 替换包含 Powered by 的多行内容
        sed -i '/<a class="luci-link".*Powered by.*<\/a>/,/<%= ver\.distversion %>/c\\t\tPowered by ImmortalWrt / Build by bluehj '"$WRT_DATE_SHORT" "$HTM_FILE" 2>/dev/null
    done
    echo "Argon theme footer has been modified!"
fi

CFG_FILE="./package/base-files/files/bin/config_generate"

#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE

#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#临时修复luci无法保存的问题
sed -i "s/\[sid\]\.hasOwnProperty/\[sid\]\?\.hasOwnProperty/g" $(find ./feeds/luci/modules/luci-base/ -type f -name "uci.js")

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
#echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#移除advancedplus无用功能
sed -i '/advancedplus\/advancedset/d' $(find ./**/luci-app-advancedplus/luasrc/controller/ -type f -name "advancedplus.lua")
sed -i '/advancedplus\/advancedipk/d' $(find ./**/luci-app-advancedplus/luasrc/controller/ -type f -name "advancedplus.lua")
sed -i '/^start() {/,/^}$/ { /advancedset/s/^\(.*advancedset.*\)$/#\1/ }' $(find ./**/luci-app-advancedplus/root/etc/ -type f -name "advancedplus")

#高通平台调整
DTS_PATH="./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#开启sqm-nss插件
	echo "CONFIG_PACKAGE_luci-app-sqm=y" >> ./.config
	echo "CONFIG_PACKAGE_sqm-scripts-nss=y" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	if [[ "${WRT_CONFIG,,}" == *"ipq50"* ]]; then
		echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
	else
		echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> ./.config
	fi
	#无WIFI配置调整Q6大小
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "qualcommax set up nowifi successfully!"
	fi
fi

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

#编译器优化
if [[ $WRT_TARGET == *"IPQ"* ]]; then
	echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
	echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config
fi

#IPK/APK包管理调整
if [[ $WRT_USEAPK == 'true' ]]; then
	echo "CONFIG_USE_APK=y" >> ./.config
	echo "APK package management has been enabled!"
else
	echo "CONFIG_USE_APK=n" >> ./.config
	echo "CONFIG_PACKAGE_default-settings-chn=y" >> ./.config
	DEFAULT_CN_FILE=./package/emortal/default-settings/files/99-default-settings-chinese
	if [ -f "$DEFAULT_CN_FILE" ]; then
		sed -i.bak "/^exit 0/r $GITHUB_WORKSPACE/Scripts/patches/99-default-settings-chinese" $DEFAULT_CN_FILE
		sed -i '/^exit 0/d' $DEFAULT_CN_FILE && echo "exit 0" >> $DEFAULT_CN_FILE
		echo "99-default-settings-chinese patch has been applied!"
	fi
	echo "IPK package management has been enabled!"
fi

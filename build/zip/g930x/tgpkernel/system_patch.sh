#!/sbin/sh
# Created by tkkg1994, modified by djb77

# Remove wrong build.prop entries
sed -i /timaversion/d /system/build.prop
sed -i /security.mdpp.mass/d /system/build.prop
sed -i /ro.hardware.keystore/d /system/build.prop

# Setting correct fingerprint files
rm -rf /system/app/TuiService /system/app/mcRegistry
rm -f /system/vendor/lib/libsecure_storage.so
rm -f /system/vendor/lib/libsecure_storage_jni.so
rm -f /system/vendor/lib64/libsecure_storage.so
rm -f /system/vendor/lib64/libsecure_storage_jni.so

# Remvoe old PersonalPageService APK
rm -rf /system/priv-app/PersonalPageService

# Copy Wavelock.sh to PHH Superuser (if exists)
if [ ! -d /magisk/phh/su.d ];then
	cp -f /tmp/tgpkernel/wavelock.sh /magisk/phh/su.d/wavelock.sh
	chown 0:0 /magisk/phh/su.d/wavelock.sh
	chmod 755 /magisk/phh/su.d/wavelock.sh
fi

# Copy Wavelock.sh to SuperSU (if exists)
if [ ! -d /su/su.d ];then
	cp -f /tmp/tgpkernel/wavelock.sh /su/su.d/wavelock.sh
	chown 0:0 /su/su.d/wavelock.sh
	chmod 700 /su/su.d/wavelock.sh
fi

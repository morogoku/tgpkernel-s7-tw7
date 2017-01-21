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


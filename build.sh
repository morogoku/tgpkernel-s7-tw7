#!/bin/bash
# kernel build script by Tkkg1994 v0.4 (optimized from apq8084 kernel source)
# Modified by djb77 / XDA Developers
# TGPKernel Script Version: v2.11

# ---------
# VARIABLES
# ---------
BUILD_SCRIPT=2.11
VERSION_NUMBER=$(<build/version)
ARCH=arm64
BUILD_CROSS_COMPILE=~/android/toolchains/aarch64-cortex_a53-linux-gnueabi-GNU-6.3.0/bin/aarch64-cortex_a53-linux-gnueabi-
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0

# ---------
# FUNCTIONS
# ---------
FUNC_CLEAN()
{
echo "Cleaning Workspace"
make clean
make ARCH=arm64 distclean
rm -rf $RDIR/arch/arm64/boot/dtb
rm -f $RDIR/arch/$ARCH/boot/dts/*.dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-zImage
rm -f $RDIR/build/boot.img
rm -f $RDIR/build/*.zip
rm -f $RDIR/build/ramdisk/g930x/image-new.img
rm -f $RDIR/build/ramdisk/g930x/ramdisk-new.cpio.gz
rm -f $RDIR/build/ramdisk/g930x/split_img/boot.img-dtb
rm -f $RDIR/build/ramdisk/g930x/split_img/boot.img-zImage
rm -f $RDIR/build/ramdisk/g930x/image-new.img
rm -f $RDIR/build/ramdisk/g935x/ramdisk-new.cpio.gz
rm -f $RDIR/build/ramdisk/g935x/split_img/boot.img-dtb
rm -f $RDIR/build/ramdisk/g935x/split_img/boot.img-zImage
rm -f $RDIR/build/zip/g930x/*.zip
rm -f $RDIR/build/zip/g930x/*.img
rm -f $RDIR/build/zip/g935x/*.zip
rm -f $RDIR/build/zip/g935x/*.img
rm -f $RDIR/build/zip/g93xx/*.zip
rm -f $RDIR/build/zip/g93xx/*.img
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/acct/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/cache/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/data/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/dev/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/lib/modules/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/mnt/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/proc/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/storage/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/sys/.placeholder
echo "" > $RDIR/build/ramdisk/g930x/ramdisk/system/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/acct/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/cache/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/data/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/dev/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/lib/modules/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/mnt/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/proc/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/storage/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/sys/.placeholder
echo "" > $RDIR/build/ramdisk/g935x/ramdisk/system/.placeholder
}

FUNC_DELETE_PLACEHOLDERS()
{
find . -name \.placeholder -type f -delete
echo "Placeholders Deleted from Ramdisk"
echo ""
}

FUNC_BUILD_ZIMAGE()
{
echo ""
echo "build common config="$KERNEL_DEFCONFIG ""
echo "build variant config="$MODEL ""
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	$KERNEL_DEFCONFIG || exit -1
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
echo ""
}

FUNC_BUILD_DTB()
{
[ -f "$DTCTOOL" ] || {
	echo "You need to run ./build.sh first!"
	exit 1
}
case $MODEL in
herolte)
	DTSFILES="exynos8890-herolte_eur_open_00 exynos8890-herolte_eur_open_01
		exynos8890-herolte_eur_open_02 exynos8890-herolte_eur_open_03
		exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
		exynos8890-herolte_eur_open_09"
	;;
hero2lte)
	DTSFILES="exynos8890-hero2lte_eur_open_00 exynos8890-hero2lte_eur_open_01
		exynos8890-hero2lte_eur_open_03 exynos8890-hero2lte_eur_open_04
		exynos8890-hero2lte_eur_open_08"
	;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
mkdir -p $OUTDIR $DTBDIR
cd $DTBDIR || {
	echo "Unable to cd to $DTBDIR!"
	exit 1
}
rm -f ./*
echo "Processing dts files."
for dts in $DTSFILES; do
	echo "=> Processing: ${dts}.dts"
	${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
	echo "=> Generating: ${dts}.dtb"
	$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
done
echo "Generating dtb.img."
$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
echo "Done."
}

FUNC_BUILD_RAMDISK()
{

if [ ! -f "$RDIR/build/ramdisk/g930x/ramdisk/config" ]; then
mkdir $RDIR/build/ramdisk/g930x/ramdisk/config
chmod 500 $RDIR/build/ramdisk/g930x/ramdisk/config
fi
if [ ! -f "$RDIR/build/ramdisk/g935x/ramdisk/config" ]; then
mkdir $RDIR/build/ramdisk/g935x/ramdisk/config
chmod 500 $RDIR/build/ramdisk/g935x/ramdisk/config
fi

mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb
case $MODEL in
herolte)
	rm -f $RDIR/build/ramdisk/g930x/split_img/boot.img-zImage
	rm -f $RDIR/build/ramdisk/g930x/split_img/boot.img-dtb
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/build/ramdisk/g930x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/build/ramdisk/g930x/split_img/boot.img-dtb
	cd $RDIR/build/ramdisk/g930x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
hero2lte)
	rm -f $RDIR/build/ramdisk/g935x/split_img/boot.img-zImage
	rm -f $RDIR/build/ramdisk/g935x/split_img/boot.img-dtb
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/build/ramdisk/g935x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/build/ramdisk/g935x/split_img/boot.img-dtb
	cd $RDIR/build/ramdisk/g935x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
}

FUNC_BUILD_BOOTIMG()
{
(
FUNC_CLEAN
FUNC_DELETE_PLACEHOLDERS
FUNC_BUILD_ZIMAGE
FUNC_BUILD_DTB
FUNC_BUILD_RAMDISK
) 2>&1	 | tee -a ./build/build.log
}

FUNC_BUILD_ZIP()
{
echo ""
echo "Building Zip File"
cd $ZIP_FILE_DIR
zip -gq $ZIP_NAME -r META-INF/ -x "*~"
zip -gq $ZIP_NAME -r system/ -x "*~" 
zip -gq $ZIP_NAME -r tgpkernel/ -x "*~" 
[ -f "$RDIR/build/zip/g930x/boot.img" ] && zip -gq $ZIP_NAME boot.img -x "*~"
[ -f "$RDIR/build/zip/g935x/boot.img" ] && zip -gq $ZIP_NAME boot.img -x "*~"
[ -f "$RDIR/build/zip/g93xx/g930x.img" ] && zip -gq $ZIP_NAME g930x.img -x "*~"
[ -f "$RDIR/build/zip/g93xx/g935x.img" ] && zip -gq $ZIP_NAME g935x.img -x "*~"
if [ -n `which java` ]; then
echo "Java Detected, Signing Zip File"
mv $ZIP_NAME old$ZIP_NAME
java -Xmx1024m -jar $RDIR/build/signapk/signapk.jar -w $RDIR/build/signapk/testkey.x509.pem $RDIR/build/signapk/testkey.pk8 old$ZIP_NAME $ZIP_NAME
rm old$ZIP_NAME
fi
chmod a+r $ZIP_NAME
mv -f $ZIP_FILE_TARGET $RDIR/build/$ZIP_NAME
cd $RDIR
}

# -------------
# PROGRAM START
# -------------
rm -rf ./build/build.log
clear
echo "-------------------------------"
echo "TGPKernel S7 Build Script v$BUILD_SCRIPT"
echo "-------------------------------"
echo "Script originally written by Tkkg1994"
echo "Modified by djb77"
echo ""
echo "Current Kernel Version: v$VERSION_NUMBER"
echo ""
echo "1) Build boot.img for S7"
echo "2) Build boot.img for S7 Edge"
echo "3) Build boot.img and .zip for S7"
echo "4) Build boot.img and .zip for S7 Edge"
echo "5) Build boot.img and .zip for S7 + S7 Edge (Seperate)"
echo "6) Build boot.img and .zip for S7 + S7 Edge (All-In-One)"
echo "7) Clean Workspace"
echo ""
read -p "Please select an option " prompt
echo ""
if [[ $prompt == "1" ]]; then
	rm -f $RDIR/build/build.log
	MODEL=herolte
	KERNEL_DEFCONFIG=tgpkernel-herolte_defconfig
	START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/ramdisk/g930x/image-new.img $RDIR/build/boot.img
	mv -f $RDIR/build/build.log $RDIR/build/build-g930f.log
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo ""
	echo "Total compiling time is $ELAPSED_TIME seconds"
	echo ""
	echo "You can now find your boot.img in the build folder"
	echo "You can now find your build-g930f.log file in the build folder"
	echo ""
elif [[ $prompt == "2" ]]; then
	rm -f $RDIR/build/build.log
	MODEL=hero2lte
	KERNEL_DEFCONFIG=tgpkernel-hero2lte_defconfig
	START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/ramdisk/g935x/image-new.img $RDIR/build/boot.img
	mv -f $RDIR/build/build.log $RDIR/build/build-g935f.log
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo ""
	echo "Total compiling time is $ELAPSED_TIME seconds"
	echo ""
	echo "You can now find your boot.img in the build folder"
	echo "You can now find your build-g935f.log file in the build folder"
	echo ""
elif [[ $prompt == "3" ]]; then
	rm -f $RDIR/build/build.log
	MODEL=herolte
	KERNEL_DEFCONFIG=tgpkernel-herolte_defconfig
	START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/ramdisk/g930x/image-new.img $RDIR/build/zip/g930x/boot.img
	mv -f $RDIR/build/build.log $RDIR/build/build-g930f.log
	ZIP_DATE=`date +%Y%m%d`
	ZIP_FILE_DIR=$RDIR/build/zip/g930x
	ZIP_NAME=TGPKernel.G930x.v$VERSION_NUMBER.$ZIP_DATE.zip
	ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
	FUNC_BUILD_ZIP
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo ""
	echo "Total compiling time is $ELAPSED_TIME seconds"
	echo ""
	echo "You can now find your .zip file in the build folder"
	echo "You can now find your build-g930f.log file in the build folder"
	echo ""
elif [[ $prompt == "4" ]]; then
	rm -f $RDIR/build/build.log
	MODEL=hero2lte
	KERNEL_DEFCONFIG=tgpkernel-hero2lte_defconfig
	START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/ramdisk/g935x/image-new.img $RDIR/build/zip/g935x/boot.img
	mv -f $RDIR/build/build.log $RDIR/build/build-g935f.log
	ZIP_DATE=`date +%Y%m%d`
	ZIP_FILE_DIR=$RDIR/build/zip/g935x
	ZIP_NAME=TGPKernel.G935x.v$VERSION_NUMBER.$ZIP_DATE.zip
	ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
	FUNC_BUILD_ZIP
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo ""
	echo "Total compiling time is $ELAPSED_TIME seconds"
	echo ""
	echo "You can now find your .zip file in the build folder"
	echo "You can now find your build-g935f.log file in the build folder"
	echo ""
elif [[ $prompt == "5" ]]; then
	rm -f $RDIR/build/build.log
	MODEL=herolte
	KERNEL_DEFCONFIG=tgpkernel-herolte_defconfig
	START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/ramdisk/g930x/image-new.img $RDIR/build/zip/g930x/boot.img-save
	mv -f $RDIR/build/build.log $RDIR/build/build-g930f.log
	rm -f $RDIR/build/build.log
	MODEL=hero2lte
	KERNEL_DEFCONFIG=tgpkernel-hero2lte_defconfig
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/zip/g930x/boot.img-save $RDIR/build/zip/g930x/boot.img
	mv -f $RDIR/build/ramdisk/g935x/image-new.img $RDIR/build/zip/g935x/boot.img
	mv -f $RDIR/build/build.log $RDIR/build/build-g935f.log
	ZIP_DATE=`date +%Y%m%d`
	ZIP_FILE_DIR=$RDIR/build/zip/g930x
	ZIP_NAME=TGPKernel.G930x.v$VERSION_NUMBER.$ZIP_DATE.zip
	ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
	FUNC_BUILD_ZIP
	ZIP_FILE_DIR=$RDIR/build/zip/g935x
	ZIP_NAME=TGPKernel.G935x.v$VERSION_NUMBER.$ZIP_DATE.zip
	ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
	FUNC_BUILD_ZIP
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo ""
	echo "Total compiling time is $ELAPSED_TIME seconds"
	echo ""
	echo "You can now find your .zip files in the build folder"
	echo "You can now find your build-g930f.log file in the build folder"
	echo "You can now find your build-g935f.log file in the build folder"
	echo ""
elif [[ $prompt == "6" ]]; then
	rm -f $RDIR/build/build.log
	MODEL=herolte
	KERNEL_DEFCONFIG=tgpkernel-herolte_defconfig
	START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/ramdisk/g930x/image-new.img $RDIR/build/zip/g93xx/g930x.img-save
	mv -f $RDIR/build/build.log $RDIR/build/build-g930f.log
	rm -f $RDIR/build/build.log
	MODEL=hero2lte
	KERNEL_DEFCONFIG=tgpkernel-hero2lte_defconfig
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a ./build/build.log
	mv -f $RDIR/build/zip/g93xx/g930x.img-save $RDIR/build/zip/g93xx/g930x.img
	mv -f $RDIR/build/ramdisk/g935x/image-new.img $RDIR/build/zip/g93xx/g935x.img
	mv -f $RDIR/build/build.log $RDIR/build/build-g935f.log
	ZIP_DATE=`date +%Y%m%d`
	ZIP_FILE_DIR=$RDIR/build/zip/g93xx
	ZIP_NAME=TGPKernel.G93xx.v$VERSION_NUMBER.$ZIP_DATE.zip
	ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
	FUNC_BUILD_ZIP
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo ""
	echo "Total compiling time is $ELAPSED_TIME seconds"
	echo ""
	echo "You can now find your .zip file in the build folder"
	echo "You can now find your build-g930f.log file in the build folder"
	echo "You can now find your build-g935f.log file in the build folder"
	echo ""
elif [[ $prompt == "7" ]]; then
	rm -f $RDIR/build/build.log
	rm -f $RDIR/build/build-g930f.log
	rm -f $RDIR/build/build-g935f.log
	FUNC_CLEAN
fi


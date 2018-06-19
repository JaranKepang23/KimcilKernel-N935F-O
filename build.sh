#!/bin/bash
# kernel build script by Tkkg1994 v0.6 (optimized from apq8084 kernel source)

export MODEL=gracelte
export ARCH=arm64
export VERSION=V2.0.0
export BUILD_CROSS_COMPILE=~/Desktop/kernel/toolchains/aarch64-cortex_a53-linux-gnueabi-gcc-6/bin/aarch64-cortex_a53-linux-gnueabi-
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
KERNELNAME=KimcilKernel
KERNEL_VERSION=V2.0.0
PAGE_SIZE=2048
DTB_PADDING=0

FUNC_DEFCONFIG()
{
case $MODEL in
gracelte)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos8890-gracelte_defconfig
		;;
	kor)
		KERNEL_DEFCONFIG=exynos8890-${MODEL}kor_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
}

FUNC_CLEAN()
{
echo ""
echo "Deleting old work files"
echo ""
make -s clean
make -s ARCH=arm64 distclean
rm -f $RDIR/build/*.img
rm -f $RDIR/build/*.log
rm -rf $RDIR/arch/arm64/boot/dtb
rm -f $RDIR/arch/$ARCH/boot/dts/*.dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-zImage
rm -f $RDIR/ramdisk/SM-N935F/image-new.img
rm -f $RDIR/ramdisk/SM-N935F/ramdisk-new.cpio.gz
rm -f $RDIR/ramdisk/SM-N935F/split_img/boot.img-dtb
rm -f $RDIR/ramdisk/SM-N935F/split_img/boot.img-zImage
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/acct/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/cache/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/data/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/dev/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/lib/modules/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/mnt/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/proc/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/storage/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/sys/Placeholder
echo "" > $RDIR/ramdisk/SM-N935F/ramdisk/system/Placeholder
}

FUNC_CLEAN_DTB()
{
	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "no directory : "$RDIR/arch/$ARCH/boot/dts""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm $RDIR/arch/$ARCH/boot/dtb/*.dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-zImage
	fi
}

FUNC_BUILD_DTIMAGE_TARGET()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_DTB-IMAGE"
        echo "=============================================="
        echo ""
	[ -f "$DTCTOOL" ] || {
		echo "You need to run ./build.sh first!"
		exit 1
	}

	case $MODEL in
	gracelte)
		case $VARIANT in
		can|duos|eur|xx)
			DTSFILES="exynos8890-gracelte_eur_open_00 exynos8890-gracelte_eur_open_01
				exynos8890-gracelte_eur_open_02 exynos8890-gracelte_eur_open_03
				exynos8890-gracelte_eur_open_05 exynos8890-gracelte_eur_open_07
				exynos8890-gracelte_eur_open_09 exynos8890-gracelte_eur_open_11"
			;;
		kor)
			DTSFILES="exynos8890-gracelte_kor_all_01 exynos8890-gracelte_kor_all_02
				exynos8890-gracelte_kor_all_03 exynos8890-gracelte_kor_all_05
				exynos8890-gracelte_kor_all_07 exynos8890-gracelte_kor_all_09
				exynos8890-gracelte_kor_all_11 exynos8890-gracelte_kor_all_12"
			;;
	*)
		echo "Unknown device: $VARIANT"
		exit 1
		;;
		esac
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

	echo "Processing dts files..."

	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
	echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done

	echo "Generating dtb.img..."
	$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE

	echo "Done."
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build model config="$MODEL ""
	echo "build job number= " $BUILD_JOB_NUMBER ""

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_RAMDISK"
        echo "=============================================="
        echo
	mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb

	case $MODEL in
	gracelte)
		case $VARIANT in
		can|duos|eur|xx)
			mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-N935F/split_img/boot.img-zImage
			mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-N935F/split_img/boot.img-dtb
			cd $RDIR/ramdisk/SM-N935F
			./repackimg.sh --nosudo
			echo SEANDROIDENFORCE >> image-new.img
			;;
		kor)
			mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-N935K/split_img/boot.img-zImage
			mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-N935K/split_img/boot.img-dtb
			cd $RDIR/ramdisk/SM-N935K
			./repackimg.sh --nosudo
			echo SEANDROIDENFORCE >> image-new.img
			;;
	*)
		echo "Unknown device: $VARIANT"
		exit 1
		;;
	esac
;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
	esac
	echo ""
        echo "=============================================="
        echo "END : FUNC_BUILD_RAMDISK"
        echo "=============================================="
        echo
}

FUNC_BUILD_ZIP()
{
	echo ""
	echo "================================="
	echo "          FUNC_BUILD_ZIP         "
	echo "================================="
	echo ""
	cd $RDIR/build
	rm $MODEL-$VARIANT.img
	case $MODEL in
	gracelte)
		case $VARIANT in
		can|duos|eur|xx)
			mv -f $RDIR/ramdisk/SM-N935F/image-new.img $RDIR/build/$MODEL-$VARIANT.img
			;;
		kor)
			mv -f $RDIR/ramdisk/SM-N935K/image-new.img $RDIR/build/$MODEL-$VARIANT.img
			;;
	*)
		echo "Unknown device: $VARIANT"
		exit 1
		;;
	esac
;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
	esac
	echo " "
	echo "Creating flashable zip..."
	echo " "
	zip -r -x .gitignore -9 ../$KERNELNAME-$KERNEL_VERSION-N935XX.zip .
	echo "DONE.........!!!!!!!!"
}

OPTION_0()
{
FUNC_CLEAN
exit
}

OPTION_1()
{
(
rm $RDIR/arch/$ARCH/boot/Image
FUNC_BUILD_KERNEL
mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
rm -f $RDIR/ramdisk/SM-N935F/split_img/boot.img-zImage
mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-N935F/split_img/boot.img-zImage
) 2>&1	 | tee -a ./build.log
exit
}

OPTION_2()
{
(
	export VARIANT=eur
	FUNC_DEFCONFIG
	START_TIME=`date +%s`
	rm $RDIR/arch/$ARCH/boot/Image
	rm $RDIR/arch/$ARCH/boot/dts/*.dtb
	rm -rf $RDIR/arch/arm64/boot/dtb
	FUNC_BUILD_KERNEL
	FUNC_BUILD_DTIMAGE_TARGET
	rm -f $RDIR/ramdisk/SM-N935F/split_img/boot.img-zImage
	rm -f $RDIR/ramdisk/SM-N935F/split_img/boot.img-dtb
	FUNC_BUILD_RAMDISK
	FUNC_BUILD_ZIP

	END_TIME=`date +%s`
	
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time was $ELAPSED_TIME seconds"
	echo "build common config="$KERNEL_DEFCONFIG ""
	echo "ARCH = "$ARCH ""
	echo "toolchain = "$BUILD_CROSS_COMPILE ""
) 2>&1	 | tee -a ./build.log
exit
}

OPTION_3()
{
(
FUNC_BUILD_RAMDISK
FUNC_BUILD_ZIP
) 2>&1	 | tee -a ./build.log
exit
}

OPTION_4()
{
(
	export VARIANT=kor
	FUNC_DEFCONFIG
	START_TIME=`date +%s`
	rm $RDIR/arch/$ARCH/boot/Image
	rm $RDIR/arch/$ARCH/boot/dts/*.dtb
	rm -rf $RDIR/arch/arm64/boot/dtb
	FUNC_BUILD_KERNEL
	FUNC_BUILD_DTIMAGE_TARGET
	rm -f $RDIR/ramdisk/SM-N935F/split_img/boot.img-zImage
	rm -f $RDIR/ramdisk/SM-N935F/split_img/boot.img-dtb
	FUNC_BUILD_RAMDISK
	FUNC_BUILD_ZIP

	END_TIME=`date +%s`
	
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time was $ELAPSED_TIME seconds"
	echo "build common config="$KERNEL_DEFCONFIG ""
	echo "ARCH = "$ARCH ""
	echo "toolchain = "$BUILD_CROSS_COMPILE ""
) 2>&1	 | tee -a ./build.log
exit
}

# ----------------------------------
# CHECK COMMAND LINE FOR ANY ENTRIES
# ----------------------------------
if [ $1 == 0 ]; then
	OPTION_0
fi
if [ $1 == 1 ]; then
	OPTION_1
fi
if [ $1 == 2 ]; then
	OPTION_2
fi
if [ $1 == 3 ]; then
	OPTION_3
fi
if [ $1 == 4 ]; then
	OPTION_4
fi

# -------------
# PROGRAM START
# -------------
rm -rf ./build.log
clear
echo ""
echo " 0) Clean Workspace"
echo ""
echo " 1) Build Zimage Only"
echo " 2) Build All"
echo " 3) Build Boot.img & Zipping"
echo " 4) Build Kor Version"
echo ""
echo " 9) Exit"
echo ""
read -p "Please select an option " prompt
echo ""
if [ $prompt == "0" ]; then
	OPTION_0
elif [ $prompt == "1" ]; then
	OPTION_1
elif [ $prompt == "2" ]; then
	OPTION_2
elif [ $prompt == "3" ]; then
	OPTION_3
elif [ $prompt == "4" ]; then
	OPTION_4
elif [ $prompt == "9" ]; then
	exit
fi


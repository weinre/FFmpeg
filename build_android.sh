# 切换到 FFmpeg 的目录
cd /Users/whensunset/AndroidStudioProjects/KSVideoProject/ffmpeg

# NDK的路径，根据自己的安装位置进行设置
export NDK=/Users/whensunset/AndroidStudioProjects/KSVideoProject/android-ndk-r14b
export SYSROOT=$NDK/platforms/android-16/arch-arm/
export TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
export CPU=arm
export PLATFORM=$NDK/platforms/android-14/arch-arm

# 配置编译后的产物放置路径
export PREFIX=$(pwd)/android/$CPU
export ADDI_CFLAGS="-marm"

# 创建一个方法，这个方法使用 configure 这个文件传入一些参数来对 FFmpeg 进行编译，可以使用 configure -help 命令来对参数进行了解
function build_one
{
./configure \
--prefix=$PREFIX \
--target-os=android \
--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
--arch=arm \
--sysroot=$PLATFORM \
--extra-cflags="-I$PLATFORM/usr/include" \
--cc=$TOOLCHAIN/bin/arm-linux-androideabi-gcc \
--nm=$TOOLCHAIN/bin/arm-linux-androideabi-nm \
--disable-shared \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-ffserver \
--disable-doc \
--disable-symver \
--enable-small \
--enable-gpl \
--enable-asm \
--enable-jni \
--enable-mediacodec \
--enable-decoder=h264_mediacodec \
--enable-hwaccel=h264_mediacodec \
--enable-decoder=hevc_mediacodec \
--enable-decoder=mpeg4_mediacodec \
--enable-decoder=vp8_mediacodec \
--enable-decoder=vp9_mediacodec \
--enable-nonfree \
--enable-version3 \
--extra-cflags="-Os -fpic $ADDI_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
$ADDITIONAL_CONFIGURE_FLAG
make clean
make -j8
make install
$TOOLCHAIN/bin/arm-linux-androideabi-ld \
-rpath-link=$PLATFORM/usr/lib \
-L$PLATFORM/usr/lib \
-L$PREFIX/lib \
-soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
$PREFIX/libffmpeg.so \
libavcodec/libavcodec.a \
libavfilter/libavfilter.a \
libswresample/libswresample.a \
libavformat/libavformat.a \
libavutil/libavutil.a \
libswscale/libswscale.a \
libavdevice/libavdevice.a \
libpostproc/libpostproc.a \
-lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
$TOOLCHAIN/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a
}

## 运行前面创建的编译 FFmpeg 的方法
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
ADDI_CFLAGS="-marm"
build_one

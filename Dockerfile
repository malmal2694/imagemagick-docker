FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ARG IM_VERSION=7.1.0-45
ARG LIB_HEIF_VERSION=1.12.0
ARG LIB_AOM_VERSION=3.4.0
ARG LIB_WEBP_VERSION=1.2.3

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y git make gcc pkg-config autoconf curl g++ \
    # libaom
    yasm cmake \
    # libheif
    libde265-0 libde265-dev libjpeg-turbo8 libjpeg-turbo8-dev x265 libx265-dev libtool \
    # libwebp
    libsdl1.2-dev libgif-dev \
    # IM
    libpng16-16 libpng-dev libjpeg-turbo8 libjpeg-turbo8-dev libgomp1 ghostscript libxml2-dev libxml2-utils libtiff-dev libfontconfig1-dev libfreetype6-dev fonts-dejavu liblcms2-2 liblcms2-dev \
    # Install manually to prevent deleting with -dev packages
    libxext6 && \
    # Building libwebp
    git clone https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && git checkout v${LIB_WEBP_VERSION} && \
    ./autogen.sh && ./configure --enable-shared --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux --enable-static=no && \
    make && make install && \
    ldconfig /usr/local/lib && \
    cd ../ && rm -rf libwebp && \
    # Building libaom
    git clone -b v${LIB_AOM_VERSION} --depth 1 https://aomedia.googlesource.com/aom && \
    mkdir build_aom && \
    cd build_aom && \
    cmake ../aom/ -DENABLE_TESTS=0 -DBUILD_SHARED_LIBS=1 && make && make install && \
    ldconfig /usr/local/lib && \
    cd .. && \
    rm -rf aom && \
    rm -rf build_aom && \
    # Building libheif
    curl -L https://github.com/strukturag/libheif/releases/download/v${LIB_HEIF_VERSION}/libheif-${LIB_HEIF_VERSION}.tar.gz -o libheif.tar.gz && \
    tar -xzvf libheif.tar.gz && cd libheif-${LIB_HEIF_VERSION}/ && ./autogen.sh && ./configure && make && make install && cd .. && \
    ldconfig /usr/local/lib && \
    rm -rf libheif-${LIB_HEIF_VERSION} && rm libheif.tar.gz && \
    # Building ImageMagick
    git clone -b ${IM_VERSION} --depth 1 https://github.com/ImageMagick/ImageMagick.git && \
    cd ImageMagick && \
    ./configure --with-magick-plus-plus=yes --disable-docs --disable-static --with-tiff && \
    make && make install && \
    ldconfig /usr/local/lib && \
    # Remove all installed packages except gcc, g++, pkg-config for building C/C++ APIs
    apt-get remove --autoremove --purge -y make cmake curl yasm git autoconf libpng-dev libjpeg-turbo8-dev libde265-dev libx265-dev libxml2-dev libtiff-dev libfontconfig1-dev libfreetype6-dev liblcms2-dev libsdl1.2-dev libgif-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /ImageMagick


bsp_reset() {
    BSP_ARCH="arm64"
    BSP_GIT=
    BSP_TAG=
    BSP_COMMIT=
    BSP_BRANCH=
    BSP_DEFCONFIG="defconfig"

    BSP_MAKE_TARGETS="all bindeb-pkg"
    BSP_DPKG_FLAGS="-d"
}

bsp_version() {
    make -C "$TARGET_DIR" -s kernelversion
}

bsp_prepare() {
    return
}

bsp_make() {
    local BSP_VERSION="$(bsp_version)"

    make -C "$TARGET_DIR" -j$(nproc) \
        ARCH=$BSP_ARCH CROSS_COMPILE=$CROSS_COMPILE \
        KDEB_COMPRESS="xz" DPKG_FLAGS=$BSP_DPKG_FLAGS \
        LOCALVERSION=-$FORK KERNELRELEASE=$BSP_VERSION-$FORK KDEB_PKGVERSION=$BSP_VERSION-$FORK-$PKG_REVISION \
        $@
}

bsp_makedeb() {
    mv $SCRIPT_DIR/.src/*.deb ./
    for BOARD in ${SUPPORTED_BOARDS[@]}
    do
        local NAMES=("linux-image-$BOARD" "linux-headers-$BOARD")
        local DESCRIPTIONS=("Radxa virtual Linux package for $BOARD" "Radxa virtual Linux header package for $BOARD")
        local DEPENDS=("linux-image-$BSP_VERSION-$FORK" "linux-headers-$BSP_VERSION-$FORK")
        for i in {0..1}
        do
            local NAME=${NAMES[$i]}
            local VERSION="$BSP_VERSION-$FORK-$PKG_REVISION"
            local URL="https://github.com/radxa-pkg/linux-image-$FORK"
            local DESCRIPTION=${DESCRIPTIONS[$i]}
            local DEPEND=${DEPENDS[$i]}
            fpm -s empty -t deb -n "$NAME" -v "$VERSION" \
                --deb-compression xz \
                --depends "$DEPEND" \
                --url "$URL" \
                --description "$DESCRIPTION" \
                --license "GPL-2+" \
                -m "Radxa <dev@radxa.com>" \
                --vendor "Radxa" \
                --force
        done
    done
}
do_install_append () {
    echo ${MENDER_ROOTFS_PART_A} >> ${D}${sysconfdir}/udev/mount.blacklist
    echo ${MENDER_ROOTFS_PART_B} >> ${D}${sysconfdir}/udev/mount.blacklist
}

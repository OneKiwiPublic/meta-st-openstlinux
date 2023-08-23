FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://weston.ini \
            file://utilities-terminal.png \
            file://ST_1366x768.png \
            file://ST13028_Linux_picto_11_1366x768.png \
            file://ST13345_Products_light_blue_24x24.png \
            file://space.png \
            file://weston.sh \
            file://weston_profile.sh \
            file://README-CHECK-GPU \
            file://somewhere.wav \
            file://autumn-in-my-heart.wav \
            file://config.db \
            file://linuxapp.tar.gz;unpack=0 \
            file://bin.tar.gz;unpack=0 \
            file://lib_ffplay1.tar.gz;unpack=0 \
            file://lib_ffplay2.tar.gz;unpack=0 \
            file://V3.4.tar.gz;unpack=0 \
            file://test.sh \
            file://setup.sh \
            "
SRC_URI_append_stm32mpcommon = " file://check-gpu "

FILES_${PN} += " ${datadir}/weston \
         ${systemd_system_unitdir}/weston@.service \
         ${sbindir}/weston.sh \
         ${sysconfdir}/etc/profile.d \
         ${sysconfdir}/xdg/weston/weston.ini \
         /home/root \
         "

#FILES_${PN} += "${prefix}/local/*"

CONFFILES_${PN} += "${sysconfdir}/xdg/weston/weston.ini"
INSANE_SKIP_${PN} = "installed-vs-shipped"

do_install_append() {
    install -d ${D}${sysconfdir}/xdg/weston/
    install -d ${D}${datadir}/weston/backgrounds
    install -d ${D}${datadir}/weston/icon

    install -m 0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston
    install -m 0644 ${WORKDIR}/utilities-terminal.png ${D}${datadir}/weston/icon/utilities-terminal.png
    install -m 0644 ${WORKDIR}/ST13345_Products_light_blue_24x24.png ${D}${datadir}/weston/icon/ST13345_Products_light_blue_24x24.png
    install -m 0644 ${WORKDIR}/ST_1366x768.png ${D}${datadir}/weston/backgrounds/ST_1366x768.png
    install -m 0644 ${WORKDIR}/ST13028_Linux_picto_11_1366x768.png ${D}${datadir}/weston/backgrounds/ST13028_Linux_picto_11_1366x768.png

    install -m 0644 ${WORKDIR}/space.png ${D}${datadir}/weston/icon/

    install -d ${D}${systemd_system_unitdir} ${D}${sbindir}
    install -m 0755  ${WORKDIR}/weston.sh ${D}${sbindir}/

    #  install -d ${D}/etc/systemd/system/ ${D}/etc/systemd/system/multi-user.target.wants/
    #  ln -s /lib/systemd/system/weston.service ${D}/etc/systemd/system/multi-user.target.wants/display-manager.service

    install -d ${D}${sysconfdir}/profile.d
    install -m 0755 ${WORKDIR}/weston_profile.sh ${D}${sysconfdir}/profile.d/

    if ${@bb.utils.contains('DISTRO_FEATURES','xwayland','true','false',d)}; then
        # uncomment modules line for support of xwayland
        sed -i -e 's,#modules=xwayland.so,modules=xwayland.so,g' ${D}${sysconfdir}/xdg/weston/weston.ini
    fi

    # check GPU
    install -d ${D}/home/root/
    #install -d ${D}${prefix}/local
    install -m 644 ${WORKDIR}/somewhere.wav ${D}/home/root/
    install -m 644 ${WORKDIR}/autumn-in-my-heart.wav ${D}/home/root/
    install -m 0755 ${WORKDIR}/test.sh ${D}/home/root/
    install -m 0755 ${WORKDIR}/setup.sh ${D}/home/root/
    install -m 0755 ${WORKDIR}/config.db ${D}/home/root/
    install -m 0755 ${WORKDIR}/V3.4.tar.gz ${D}/home/root/
    install -m 0755 ${WORKDIR}/bin.tar.gz ${D}/home/root/
    install -m 0755 ${WORKDIR}/lib_ffplay1.tar.gz ${D}/home/root/
    install -m 0755 ${WORKDIR}/lib_ffplay2.tar.gz ${D}/home/root/
    install -m 0755 ${WORKDIR}/linuxapp.tar.gz ${D}/home/root/
    #tar -xzf ${WORKDIR}/linuxapp.tar.gz -C ${D}${prefix}/local
    install -m 644 ${WORKDIR}/README-CHECK-GPU ${D}/home/root/
    if ! test -f ${D}${base_sbindir}/check-gpu; then
        install -d ${D}${base_sbindir}
        echo '#!/bin/sh' > ${WORKDIR}/check-gpu.empty
        echo '/bin/true' >> ${WORKDIR}/check-gpu.empty
        install -m 755 ${WORKDIR}/check-gpu.empty ${D}${base_sbindir}/check-gpu
    fi
}

do_install_append_stm32mpcommon() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${base_sbindir}
        install -m 755 ${WORKDIR}/check-gpu ${D}${base_sbindir}
    fi
}


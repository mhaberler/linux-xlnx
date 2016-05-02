#!/bin/bash -e
set -x

SCRIPT_PATH="$(dirname "$(readlink -f $0)")"

cd "$SCRIPT_PATH/.."

COMMIT_TIMESTAMP="$(git log -1 --pretty=format:%at)"

export ARCH=arm
export KDEB_CHANGELOG_DIST=wheezy
export DEBFULLNAME="Michael Haberler"
export DEBEMAIL="haberlerm@gmail.com"

rm -rf .build || true
mkdir .build


make O=.build jd2-mzed_defconfig

KVERSION=$(make -s O=.build kernelversion)

LOCALVERSION=$(cat localversion-rt)
SHA1SHORT=$(git rev-parse --verify --short HEAD)
PKGVERSION=${KVERSION}${LOCALVERSION}
# undash
PKGVERSION=${PKGVERSION//-/\~}
# finale..
KDEB_PKGVERSION=${PKGVERSION}-${COMMIT_TIMESTAMP}.git${SHA1SHORT}

cd .build

make  KBUILD_DEBARCH=armhf KDEB_PKGVERSION=${KDEB_PKGVERSION} CC=/host-rootfs/usr/bin/arm-linux-gnueabihf-gcc deb-pkg -j16

# move results
mkdir -p ../.output || true
mv ../*deb ../.output

# cleanup
rm -rf *.changes
rm -rf ../.build

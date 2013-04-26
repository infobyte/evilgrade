#!/bin/bash

	#create package dpkg-deb -b seed-debian/ seed-debian_0.3_all.deb

# Ej:
# cat Packages.bz2 | bzip2 -d | > newPack
# sh inject_agent_packages.sh ../../agent/debian/seed-debian_0.3_all.deb newPack  > to_inject ; bzip2 to_inject ; mv to_inject.bz2 Packages.bz2

# could be done automatically, but to avoid messing something...
if [ $# -ne 2 ]
then
echo "$0 [pkg.deb] [Packages] > newfile"
exit 0
fi

md5=`md5sum $1|cut -d ' ' -f1`
sha1=`sha1sum $1|cut -d ' ' -f1`
sha256=`sha256sum $1|cut -d ' ' -f1`
size=`stat -c %s $1`


cat "$2"|sed -e "s/^Size: .*/Size: $size/"  |sed -e "s/MD5sum: .*/MD5Sum: $md5/" | sed -e "s/SHA1: .*/SHA1: $sha1/"|sed -e "s/SHA256: .*/SHA256: $sha256/"|sed -e 's/Depends: .*/Depends: seed-debian/'

echo "
Package: seed-debian
Priority: required
Section: system
Maintainer: debian-maint <debian@apackages.debian.org>
Architecture: all
Version: 0.2
Filename: pool/main/s/seed-debian/seed-debian_0.2_all.deb
Size: $size
MD5sum: $md5
SHA1: $sha1
SHA256: $sha256
Description: Debian Seed tool. Required for new installations.

"  



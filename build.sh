#!/bin/bash

set -o verbose
set -o errexit
set -o xtrace

vim_version="${1}"
IFS="." read -ra parts <<<"$vim_version"

centos_ver="$(rpm --eval '%{centos_ver}')"

# Install dependencies
dnf group install -y 'RPM Development Tools'
dnf install -y dnf-plugins-core
dnf copr -y enable mrsipan/clean-python
dnf install -y clean_python39 \
               gcc \
               autoconf \
               make

rm *.tar* || true
rm *.rpm || true

curl -OL "https://github.com/vim/vim/archive/${vim_version}.tar.gz"

gzip -d ${vim_version}.tar.gz
rm ${vim_version}.tar.gz || true

tar -u -f ${vim_version}.tar vim8.spec
gzip -c ${vim_version}.tar > ${vim_version}.tar.gz

rpmbuild -ts --nodeps \
                      --define "baseversion ${parts[0]:1}.${parts[1]}" \
                      --define "vimdir vim${parts[0]:1}${parts[1]}" \
                      --define "patchlevel ${parts[2]}" \
                      --define "_sourcedir `pwd`" \
                      --define "_srcrpmdir `pwd`" \
                      ${vim_version}.tar.gz

dnf builddep -y *.src.rpm

rpmbuild --rebuild \
                   --define "baseversion ${parts[0]:1}.${parts[1]}" \
                   --define "vimdir vim${parts[0]:1}${parts[1]}" \
                   --define "patchlevel ${parts[2]}" \
                   --define "_rpmdir `pwd`/rpms" \
                   *.rpm

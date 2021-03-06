#!/usr/bin/env bash
BUILD_VER=`grep 'version=' ../src/wslu-header | cut -d'=' -f 2 | xargs`
CURRENT_DIR=`pwd`

mkdir -p ~/rpm_wslu/{BUILD/,RPMS/,SOURCES/,SPECS/,SRPMS/}


mkdir -p ~/rpm_wslu/SOURCES/wslu-$BUILD_VER/{etc,mime}
cp ../out/wsl* ~/rpm_wslu/SOURCES/wslu-$BUILD_VER
cp ../src/etc/* ~/rpm_wslu/SOURCES/wslu-$BUILD_VER/etc
cp ../src/mime/* ~/rpm_wslu/SOURCES/wslu-$BUILD_VER/mime
cd ~/rpm_wslu/SOURCES
tar -czvf wslu-${BUILD_VER}.tar.gz wslu-$BUILD_VER
rm -rf wslu-$BUILD_VER

cat <<EOF >> ~/rpm_wslu/SPECS/wslu-$BUILD_VER.spec
%define packager       patrick330602 <wotingwu@live.com>

%define _topdir        $HOME/rpm_wslu
%define _tmppath       /var/tmp
 
%define _rpmtopdir     %{_topdir}
%define _builddir      %{_rpmtopdir}/BUILD
%define _rpmdir        %{_rpmtopdir}/RPMS
%define _sourcedir     %{_rpmtopdir}/SOURCES
%define _specdir       %{_rpmtopdir}/SPECS
%define _srcrpmdir     %{_rpmtopdir}/SRPMS
Summary: Windows 10 Linux Subsystem Utilities
Name: wslu
Version: $BUILD_VER
Release: 2
Source: wslu-$BUILD_VER.tar.gz
Requires: bc wget unzip
Requires(post): %{_sbindir}/update-alternatives
Requires(postun): %{_sbindir}/update-alternatives
URL: https://github.com/patrick330602/wslu/
License: GPLv3+
%description
This is a collection of utilities for Windows 10 Linux Subsystem, such as enabling sound in WSL or creating your favorite linux app shortcuts on Windows 10 Desktop. Requires Windows 10 Creators Update and higher.
%prep
%setup
%build

%install
rm -rf \$RPM_BUILD_ROOT
mkdir -p \${RPM_BUILD_ROOT}/usr/bin
mkdir -p \${RPM_BUILD_ROOT}/usr/share/wslu
mkdir -p \${RPM_BUILD_ROOT}/usr/lib/mime/packages
install -m 755 wsl* \${RPM_BUILD_ROOT}%{_bindir}
install -m 555 etc/wsl.ico \${RPM_BUILD_ROOT}/usr/share/wslu
install -m 555 etc/runHidden.vbs \${RPM_BUILD_ROOT}/usr/share/wslu

%post
%{_sbindir}/update-alternatives --install %{_bindir}/www-browser www-browser %{_bindir}/wslview 1
%{_sbindir}/update-alternatives --install %{_bindir}/x-www-browser x-www-browser %{_bindir}/wslview 1


%postun
if [ $1 -eq 0 ]; then
  %{_sbindir}/update-alternatives --remove www-browser %{_bindir}/wslview
  %{_sbindir}/update-alternatives --remove x-www-browser %{_bindir}/wslview
fi  
%clean
rm -rf \$RPM_BUILD_ROOT
%files
%defattr(-,root,root)
%attr(755,root,root) %{_bindir}/wslusc
%attr(755,root,root) %{_bindir}/wslfetch
%attr(755,root,root) %{_bindir}/wslsys
%attr(755,root,root) %{_bindir}/wslupath
%attr(755,root,root) %{_bindir}/wslview
%attr(555,root,root) /usr/share/wslu/runHidden.vbs
%attr(555,root,root) /usr/share/wslu/wsl.ico
%changelog
* Wed Jul 25 2018 patrick330602 <wotingwu@live.com>
- fix a typo in wslfetch;
- fixed a bug in wslupath with -H parameter;
- wslusc update: icon support and hidden command prompt for GUI application;
EOF

cd ~/rpm_wslu/SPECS
sudo rpmbuild -ba wslu-$BUILD_VER.spec

[ -d $CURRENT_DIR/../target ] || mkdir $CURRENT_DIR/../target
cp ~/rpm_wslu/RPMS/x86_64/*.rpm $CURRENT_DIR/../target/
cp ~/rpm_wslu/SRPMS/*.rpm $CURRENT_DIR/../target/
sudo rm -rf ~/rpm_wslu/
cd $CURRENT_DIR

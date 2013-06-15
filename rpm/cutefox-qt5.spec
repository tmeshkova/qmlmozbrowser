%define dest_obj_dir objdir

Name:       cutefox
Summary:    Cutefox browser
Version:    0.2
Release:    1
Group:      Applications/Internet
License:    Mozilla License
URL:        https://github.com/tmeshkova/qmlmozbrowser
Source0:    %{name}-%{version}.tar.bz2
Source1:    runcutefox.sh
Source2:    cutefox-large.png
Source3:    cutefox.desktop
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5Network)
BuildRequires:  pkgconfig(Qt5OpenGL)
BuildRequires:  pkgconfig(Qt5Widgets)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  qtmozembed-qt5-devel
BuildRequires:  qt5-default
Requires:  embedlite-components-qt5

%description
Cutefox browser based on Gecko and written in Qt/QML

%prep
%setup -q -n %{name}-%{version}

%build
DEST_OBJ_DIR=objdir
%qmake OBJ_DEB_DIR=$DEST_OBJ_DIR
make %{?jobs:-j%jobs}

%install
%{__rm} -rf %{buildroot}
%qmake_install

%{__mkdir} -p %{buildroot}/usr/share/applications
%{__mkdir} %{buildroot}/usr/share/cutefox
%{__install} -m 644 %{SOURCE2} %{buildroot}%{_datadir}/cutefox
%{__install} -m 644 %{SOURCE3} %{buildroot}%{_datadir}/applications/
%{__install} -m 755 %{SOURCE1} %{buildroot}/usr/bin/

%files
%defattr(-,root,root,-)
%attr(0755,root,root) %{_bindir}/*
%{_datadir}/*


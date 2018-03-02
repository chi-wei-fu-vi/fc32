@RPM_COPYRIGHT@

# @CMAKE_GEN_TIMESTAMP@

%define _rpmdir      @CMAKE_CURRENT_BINARY_DIR@/_CPack_Packages/Linux/RPM
%define _rpmfilename @CPACK_PACKAGE_FILE_NAME@.rpm
%define _topdir      @CMAKE_CURRENT_BINARY_DIR@/_CPack_Packages/Linux/RPM

Name:           @CPACK_PACKAGE_NAME@
Provides:       @PROJECT@
Version:        @CPACK_PACKAGE_VERSION@
Release:        @CPACK_PACKAGE_RELEASE@
BuildArch:      @CPACK_RPM_PACKAGE_ARCHITECTURE@
BuildRoot:      @CMAKE_CURRENT_BINARY_DIR@/_CPack_Packages/Linux/RPM/@CPACK_PACKAGE_FILE_NAME@
Summary:        FPGA Bitfile for @PROJECT@ Hardware Monitoring Probe.
Group:          Applications/System
License:        Restricted
Vendor:         Virtual Instruments


%description
FPGA Bitfile for @PROJECT@ Hardware Monitoring Probe.


%install


%files
%defattr(-,root,root)
/usr/local/vi/bin/*.rbf
/usr/local/vi/bin/regmap_versionDate.FPGA.txt


%changelog
* Tue Oct 6 2015 Jacob Alexander <jacob.alexander@virtualinstruments.com>
  Updated for mulitple rbf files
* Fri Jun 27 2014 Jacob Alexander <jacob.alexander@virtualinstruments.com>
  Created


###| CMAKE RPM Configuration |###
#
# Jacob Alexander 2014
#
###


###
# Dependencies
#

#| RPM Builds requires rpmbuild
find_package( RPM )

if ( NOT RPM_FOUND )
	message( WARNING "rpmbuild is missing, 'make rpm' will fail..." )
endif ()



###
# RPM Copyright Information
#

#| Uses copyright file located in the source directory
execute_process( COMMAND cat copyright
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE RPM_COPYRIGHT
	ERROR_QUIET
	OUTPUT_STRIP_TRAILING_WHITESPACE
)



###
# RPM Setup
#

#| Only RPMs are being built
set ( CPACK_GENERATOR "RPM" )

#| Installation path for all files
set ( CPACK_PACKAGING_INSTALL_PREFIX / )

#| Relocatable Packages are a pain...disabling
set ( CPACK_PACKAGE_RELOCATABLE FALSE )

#| Package Architecture
set ( CPACK_RPM_PACKAGE_ARCHITECTURE noarch )

#| Package prefix should be set from the cmake command
#set ( RPM_PREFIX nas )

#| RPM Name Format
set ( CPACK_PACKAGE_NAME ${RPM_PREFIX}-${PROJECT}-fpga )

#| Only mark RPM as dirty if not built by BuildBot officially
if ( NOT BUILDBOT_BUILD )
	set ( RPM_DIRTY LOCAL )
endif ()

#| RPM Release Number
set ( CPACK_PACKAGE_RELEASE ${RPM_DIRTY}${SVN_COMMITDATE} )

#| FPGA Register Map version is the main version number
set ( CPACK_PACKAGE_VERSION RM${REGMAP_VERSION} )

#| RPM Filename Format
set ( CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CPACK_RPM_PACKAGE_ARCHITECTURE} )

#| Base RPM .spec file to configure
set ( CPACK_RPM_USER_BINARY_SPECFILE ${CMAKE_BINARY_DIR}/rpm.spec )

#| Configure Base RPM .spec file
configure_file ( ${CMAKE_SOURCE_DIR}/rpm.spec ${CMAKE_BINARY_DIR}/rpm.spec @ONLY )

#| Configure CPack
include ( CPack )


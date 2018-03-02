# - Try to find rpm binary and libraries
#
# Usage of this module as follows:
#
#     find_package(RPM)
#
# Variables defined by this module:
#
#  RPM_FOUND                System has rpm, include and library dirs found
#  RPM_EXECUTABLE           rpm executable path
#  RPM_INCLUDE_DIR          The rpm include directories.
#  RPM_LIBRARY              The rpm library

if ( RPM_INCLUDE_DIR AND RPM_LIBRARY )
	# Already in cache, be silent
	set ( RPM_FIND_QUIETLY TRUE )
endif ()


find_program ( RPM_EXECUTABLE
	NAMES rpm
)
mark_as_advanced ( RPM_EXECUTABLE )

set ( RPM_LIBRARY )
set ( RPM_INCLUDE_DIR )

FIND_PATH ( RPM_INCLUDE_DIR rpm/rpmdb.h
	/usr/include
	/usr/local/include
)

set ( RPM_SUSPECT_VERSION "RPM_SUSPECT_VERSION-NOTFOUND" )
if ( RPM_INCLUDE_DIR )
	FIND_PATH ( RPM_SUSPECT_VERSION rpm/rpm4compat.h
		${RPM_INCLUDE_DIR}
		NO_DEFAULT_PATH
	)
	if ( RPM_SUSPECT_VERSION )
		set ( RPM_SUSPECT_VERSION "5.x" )
	else ()
		FIND_PATH ( RPM_SUSPECT_VERSION rpm/rpmlegacy.h
			${RPM_INCLUDE_DIR}
			NO_DEFAULT_PATH
		)
		if ( RPM_SUSPECT_VERSION )
			set ( RPM_SUSPECT_VERSION "4.x" )
		else ()
			set ( RPM_SUSPECT_VERSION "4.4" )
		endif ()
	endif ()
endif ()


FIND_LIBRARY ( RPM_LIBRARY NAMES rpm
	PATHS
	/usr/lib
	/usr/local/lib
)

if ( RPM_INCLUDE_DIR AND RPM_LIBRARY AND RPM_EXECUTABLE )
	execute_process ( COMMAND ${RPM_EXECUTABLE} --version
		OUTPUT_VARIABLE rpm_version
		ERROR_QUIET
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	if ( rpm_version MATCHES "^RPM version [0-9]" )
		string ( REPLACE "RPM version " "" RPM_VERSION_STRING "${rpm_version}")
	endif ()
	unset ( rpm_version )

	set( RPM_FOUND TRUE )
endif ()

MARK_AS_ADVANCED ( RPM_INCLUDE_DIR RPM_LIBRARY )

include ( FindPackageHandleStandardArgs )
find_package_handle_standard_args( RPM
	REQUIRED_VARS RPM_EXECUTABLE
	VERSION_VAR RPM_VERSION_STRING
)


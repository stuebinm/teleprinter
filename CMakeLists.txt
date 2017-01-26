## Copyright 2017 Matthias Stübinger
#
# This file is part of teleprinter.
#
# This program is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see http://www.gnu.org/licenses/.
#
###

# project name
    project (telexprinter)

    # the oldest stable cmake version we support
    cmake_minimum_required (VERSION 2.6)

    # tell cmake where its modules can be found in our project directory
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)

    # where we install data directory (if we have any)
    set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

    # what to call that directory where we install data too
    set (PKGDATADIR "${DATADIR}/teleprinter")

    set (APP_NAME "de.tum.in.stuebinm.teleprinter")
    set (GSETTINGS_PATH ${APP_NAME})
    set (EXEC_NAME "teleprinter")
    set (RELEASE_NAME "A website-generator")
    set (VERSION "0.1")
    set (VERSION_INFO "First version")


                        
    # we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
    find_package(PkgConfig)

    # now let's actually check for the required dependencies
    pkg_check_modules(DEPS REQUIRED 
        gee-0.8
        gio-2.0
    )

    add_definitions(${DEPS_CFLAGS})
    link_libraries(${DEPS_LIBRARIES})
    link_directories(${DEPS_LIBRARY_DIRS})


    # make sure we have vala
    find_package(Vala REQUIRED)
    # make sure we use vala
    include(ValaVersion)
    # make sure it's the desired version of vala
    ensure_vala_version("0.16" MINIMUM)


    # files we want to compile
    include(ValaPrecompile)
    vala_precompile(VALA_C ${EXEC_NAME}
        src/main.vala
        src/commands.vala
        src/printer.vala
        src/regex.vala
        src/feed.vala
    
    # tell what libraries to use when compiling
    PACKAGES
        gee-0.8
        posix
        gio-2.0
    )

    # call gcc
    add_executable(${EXEC_NAME} ${VALA_C})


    
    # # # # # # # # # # #  - - - Stuff for installation - - - # # # # # # # # # # #

    # install the binaries we just made
    install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
    

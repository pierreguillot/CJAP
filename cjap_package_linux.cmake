# - CMake JUCE Audio Plug-in Packaging - Linux
#
# This file contains functions for packaging the plug-ins on Linux. 


# - Prepares the packaging for the target on Linux
#
# The function prepares the scripts for the packaging.
if(CJAP_PACKAGE_ENABLED AND UNIX AND NOT APPLE)
  set(CJAP_PACKAGE_INSTALL_SCRIPT "${CJAP_PACKAGE_BUILD_PATH}/install.sh")
  file(WRITE "${CJAP_PACKAGE_INSTALL_SCRIPT}" "#!/bin/sh\nThisPath=\"$( cd -- \"$(dirname \"$0\")\" >/dev/null 2>&1 ; pwd -P )\"\n")
  file(CHMOD "${CJAP_PACKAGE_INSTALL_SCRIPT}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ)

  set(CJAP_PACKAGE_UNINSTALL_SCRIPT "${CJAP_PACKAGE_BUILD_PATH}/uninstall.sh")
  file(WRITE "${CJAP_PACKAGE_UNINSTALL_SCRIPT}" "#!/bin/sh\n")
  file(CHMOD "${CJAP_PACKAGE_UNINSTALL_SCRIPT}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ)

  # - Adds a copy command to the installer script
  set(CJAP_PACKAGE_INSTALLER_SCRIPT "${CJAP_PACKAGE_BUILD_PATH}/create-installer.sh")
  file(WRITE "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "#!/bin/sh\n\n")
  file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "rm -rf ${CJAP_PACKAGE_INSTALL_DIR} && mkdir ${CJAP_PACKAGE_INSTALL_DIR}\n")
  file(CHMOD "${CJAP_PACKAGE_INSTALLER_SCRIPT}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
  function(cjap_install_add_copy_command from)
    file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "cp -f \"${from}\" \"${CJAP_PACKAGE_INSTALL_DIR}\"\n")
  endfunction(cjap_install_add_copy_command)

  if(EXISTS "${CJAP_PACKAGE_CREDITS_FILE_PATH}")
    cjap_install_add_copy_command(${CJAP_PACKAGE_CREDITS_FILE_PATH})
  elseif(NOT CJAP_PACKAGE_CREDITS_FILE_PATH STREQUAL "")
    message(WARNING "CJAP_PACKAGE_CREDITS_FILE_PATH is defined but does not exist: ${CJAP_PACKAGE_CREDITS_FILE_PATH}")
  endif()
  if(EXISTS "${CJAP_PACKAGE_CHANGELOG_FILE_PATH}")
    cjap_install_add_copy_command(${CJAP_PACKAGE_CHANGELOG_FILE_PATH})
  elseif(NOT CJAP_PACKAGE_CHANGELOG_FILE_PATH STREQUAL "")
    message(WARNING "CJAP_PACKAGE_CHANGELOG_FILE_PATH is defined but does not exist: ${CJAP_PACKAGE_CHANGELOG_FILE_PATH}")
  endif()
  cjap_install_add_copy_command(${CJAP_PACKAGE_INSTALL_SCRIPT})
  cjap_install_add_copy_command(${CJAP_PACKAGE_UNINSTALL_SCRIPT})

  add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Package ALL ${CJAP_PACKAGE_INSTALLER_SCRIPT})
endif()

# - Enables the VST3 packaging for the target on Linux
#
# The function enables the packaging for the VST3 target.
# The VST3 will be installed in the $HOME/.vst3 directory.
function(target_enable_linux_vst3_package target)
  if(TARGET ${target}_VST3)
    get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
    get_target_property(VST3_ARTEFACT_FILE ${target}_VST3 JUCE_PLUGIN_ARTEFACT_FILE)

    # This is necessary to ensure the paths are correctly formatted
    add_custom_command(TARGET ${CJAP_PACKAGE_PROJECT_NAME}_Package POST_BUILD COMMAND ${CMAKE_COMMAND} "-Dsrc=${VST3_ARTEFACT_FILE}" "-Ddest=${CJAP_PACKAGE_INSTALL_DIR}" "-P" "${JUCE_CMAKE_UTILS_DIR}/copyDir.cmake" VERBATIM)
    
    file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "cp -rf $ThisPath/'${PLUGIN_NAME}.vst3' $HOME/.vst3\n")
    file(APPEND "${CJAP_PACKAGE_UNINSTALL_SCRIPT}" "rm -rf $HOME/.vst3/'${PLUGIN_NAME}.vst3'\n")
  endif()
endfunction(target_enable_linux_vst3_package)

# - Enables the standalone packaging for the target on Linux
#
# The function enables the packaging for the standalone target.
# The standolone will be installed in the /opt directory with
# a link in /usr/bin and a desktop launcher using the icon of
# the target if provided.
function(target_enable_linux_standalone_package target)
  if(TARGET ${target}_Standalone)
    get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
    get_target_property(ARTEFACT_FILE_STANDALONE ${target}_Standalone JUCE_PLUGIN_ARTEFACT_FILE)

    # This is necessary to ensure the paths are correctly formatted
    add_custom_command(TARGET ${CJAP_PACKAGE_PROJECT_NAME}_Package POST_BUILD COMMAND ${CMAKE_COMMAND} "-Dsrc=${ARTEFACT_FILE_STANDALONE}" "-Ddest=${CJAP_PACKAGE_INSTALL_DIR}" "-P" "${JUCE_CMAKE_UTILS_DIR}/copyDir.cmake" VERBATIM)

    file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "mkdir -p /opt/${PLUGIN_NAME}\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "cp -rf $ThisPath/'${PLUGIN_NAME}' '/opt/${PLUGIN_NAME}'\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "ln -sf '/opt/${PLUGIN_NAME}/${PLUGIN_NAME}' '/usr/bin/${PLUGIN_NAME}'\n")

    get_target_property(ICON_BIG_FILE_STANDALONE ${target} JUCE_ICON_BIG)
    get_target_property(ICON_SMALL_FILE_STANDALONE ${target} JUCE_ICON_SMALL)
    if(ICON_BIG_FILE_STANDALONE)
      cjap_install_add_copy_command(${ICON_BIG_FILE_STANDALONE})
      get_filename_component(ICON_BIG_FILE_STANDALONE_NAME "${ICON_BIG_FILE_STANDALONE}" NAME)
      file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "cp -f $ThisPath/'${ICON_BIG_FILE_STANDALONE_NAME}' '/opt/${PLUGIN_NAME}'\n")
    elseif(ICON_SMALL_FILE_STANDALONE)
      cjap_install_add_copy_command(${ICON_SMALL_FILE_STANDALONE})
      get_filename_component(ICON_SMALL_FILE_STANDALONE_NAME "${ICON_SMALL_FILE_STANDALONE}" NAME)
      file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "cp -f $ThisPath/'${ICON_SMALL_FILE_STANDALONE_NAME}' '/opt/${PLUGIN_NAME}'\n")
    endif()
    
    set(CJAP_DESKTOP_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/${PLUGIN_NAME}.desktop")
    file(WRITE ${CJAP_DESKTOP_FILE_PATH} "[Desktop Entry]\n")
    file(APPEND ${CJAP_DESKTOP_FILE_PATH} "Version = ${CJAP_PACKAGE_PROJECT_VERSION}\n")
    file(APPEND ${CJAP_DESKTOP_FILE_PATH} "Type = Application\n")
    file(APPEND ${CJAP_DESKTOP_FILE_PATH} "Terminal = false\n")
    file(APPEND ${CJAP_DESKTOP_FILE_PATH} "Name = ${PLUGIN_NAME}\n")
    file(APPEND ${CJAP_DESKTOP_FILE_PATH} "Exec = /usr/bin/'${PLUGIN_NAME}'\n")
    if(ICON_BIG_FILE_STANDALONE OR ICON_SMALL_FILE_STANDALONE)
      file(APPEND ${CJAP_DESKTOP_FILE_PATH} "Icon = /opt/'${PLUGIN_NAME}'/icon.png\n")
    endif()
    file(APPEND ${CJAP_DESKTOP_FILE_PATH} "Categories = Audio;\n")
    cjap_install_add_copy_command(${CJAP_DESKTOP_FILE_PATH})

    file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "cp -f $ThisPath/'${PLUGIN_NAME}.desktop' /usr/share/applications\n")

    file(APPEND "${CJAP_PACKAGE_UNINSTALL_SCRIPT}" "rm -rf '/opt/${PLUGIN_NAME}'\n")
    file(APPEND "${CJAP_PACKAGE_UNINSTALL_SCRIPT}" "rm -f '/usr/bin/${PLUGIN_NAME}'\n")
    file(APPEND "${CJAP_PACKAGE_UNINSTALL_SCRIPT}" "rm -f '/usr/share/applications/${PLUGIN_NAME}.desktop'\n")
  endif()
endfunction(target_enable_linux_standalone_package)

# - Enables the packaging for the target on Linux
#
# The function enables the packaging for:
# VST3 and Standalone
function(target_enable_linux_cjap_package target)
  if(CJAP_PACKAGE_ENABLED AND UNIX AND NOT APPLE)
    target_enable_linux_vst3_package(${target})
    target_enable_linux_standalone_package(${target})
    get_target_property(PACKAGE_EXTRA_ARGS ${target} CJAP_PACKAGE_EXTRA_ARGS)
    if(PACKAGE_EXTRA_ARGS)
      file(APPEND "${CJAP_PACKAGE_INSTALL_SCRIPT}" "${PACKAGE_EXTRA_ARGS}")
    endif()
  endif()
endfunction(target_enable_linux_cjap_package)

# - Adds a file to the linux package
#
# The function adds a file to install with the package.
function(linux_cjap_package_add_file file destination)
  if(CJAP_PACKAGE_ENABLED AND UNIX AND NOT APPLE)
    get_filename_component(file_name ${file} NAME)
    get_filename_component(file_name_we ${file} NAME_WE)
    string(REPLACE " " "_" file_name_we ${file_name_we})
    file(APPEND ${CJAP_PACKAGE_INSTALL_SCRIPT} "mkdir -p ${destination}\n")
    file(APPEND ${CJAP_PACKAGE_INSTALL_SCRIPT} "cp -f $ThisPath/${file_name} ${destination}\n")
    file(APPEND ${CJAP_PACKAGE_UNINSTALL_SCRIPT} "rm -f ${destination}/${file_name}\n")
    cjap_install_add_copy_command(${file})
  endif()
endfunction(linux_cjap_package_add_file)

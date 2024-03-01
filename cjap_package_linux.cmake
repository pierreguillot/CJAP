# - CMake JUCE Audio Plug-in Packaging - Linux
#
# This file contains functions for packaging the plug-ins on Linux. 

# - Prepares the packaging for the target on Linux
#
# The function prepares the scripts for the packaging.
if(CJAP_PACKAGE_ENABLED AND UNIX AND NOT APPLE)
    set(CJAP_PACKAGE_INSTALLER_SCRIPT "${CJAP_PACKAGE_BUILD_PATH}/create-installer.sh")
    file(WRITE "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "#!/bin/sh\n\n")
    file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "rm -rf ${CJAP_PACKAGE_BUILD_PATH} && mkdir ${CJAP_PACKAGE_BUILD_PATH}\n")
    if(EXISTS ${CJAP_PACKAGE_CREDITS_FILE_PATH})
      file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "cp ${CJAP_PACKAGE_CREDITS_FILE_PATH} ${CJAP_PACKAGE_BUILD_PATH}\n")
    endif()
    if(EXISTS ${CJAP_PACKAGE_CHANGELOG_FILE_PATH})
      file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "cp ${CJAP_PACKAGE_CHANGELOG_FILE_PATH} ${CJAP_PACKAGE_BUILD_PATH}\n")
    endif()
    file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "cp ${CJAP_PACKAGE_INSTALL_DIR}/install.sh ${CJAP_PACKAGE_BUILD_PATH}\n")
    file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "cp ${CJAP_PACKAGE_INSTALL_DIR}/uninstall.sh ${CJAP_PACKAGE_BUILD_PATH}\n")
    file(APPEND "${CJAP_PACKAGE_INSTALLER_SCRIPT}" "\n")
    file(CHMOD "${CJAP_PACKAGE_INSTALLER_SCRIPT}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)

    file(WRITE "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "#!/bin/sh\nThisPath=\"$( cd -- \"$(dirname \"$0\")\" >/dev/null 2>&1 ; pwd -P )\"\n")
    file(CHMOD "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ)

    file(WRITE "${CJAP_PACKAGE_INSTALL_DIR}/uninstall.sh" "#!/bin/sh\n")
    file(CHMOD "${CJAP_PACKAGE_INSTALL_DIR}/uninstall.sh" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ)
    
    add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Package ALL ${CJAP_PACKAGE_INSTALLER_SCRIPT})
endif()

# - 
function(target_add_copy_command target from to)
    add_custom_command(TARGET ${target} POST_BUILD COMMAND ${CMAKE_COMMAND} "-Dsrc=${from}" "-Ddest=${to}" "-P" "${JUCE_CMAKE_UTILS_DIR}/copyDir.cmake" VERBATIM)
endfunction()

# - Enables the VST3 packaging for the target on Linux
#
# The function enables the packaging for the VST3 target.
# The VST3 will be installed in the $HOME/.vst3 directory.
function(target_enable_linux_vst3_package target)
  if(TARGET ${target}_VST3)
    get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
    get_target_property(VST3_ARTEFACT_FILE ${target}_VST3 JUCE_PLUGIN_ARTEFACT_FILE)
    target_add_copy_command(${CJAP_PACKAGE_PROJECT_NAME}_Package "${VST3_ARTEFACT_FILE}" "${CJAP_PACKAGE_INSTALL_DIR}")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "cp -rf $ThisPath/'${PLUGIN_NAME}.vst3' $HOME/.vst3\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/uninstall.sh" "rm -rf $HOME/.vst3/'${PLUGIN_NAME}.vst3'\n")
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
    target_add_copy_command(${CJAP_PACKAGE_PROJECT_NAME}_Package "${ARTEFACT_FILE_STANDALONE}" "${CJAP_PACKAGE_INSTALL_DIR}")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "mkdir -p /opt/${PLUGIN_NAME}\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "cp -rf $ThisPath/'${PLUGIN_NAME}' '/opt/${PLUGIN_NAME}'\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "ln -sf '/opt/${PLUGIN_NAME}/${PLUGIN_NAME}' '/usr/bin/${PLUGIN_NAME}'\n")

    get_target_property(ICON_BIG_FILE_STANDALONE ${target} JUCE_ICON_BIG)
    get_target_property(ICON_SMALL_FILE_STANDALONE ${target} JUCE_ICON_SMALL)
    if(ICON_BIG_FILE_STANDALONE)
      target_add_copy_command(${CJAP_PACKAGE_PROJECT_NAME}_Package "${ICON_BIG_FILE_STANDALONE}" "${CJAP_PACKAGE_BUILD_PATH}")
      file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "cp -f $ThisPath/icon.png '/opt/${PLUGIN_NAME}'/icon.png'\n")
    elseif(ICON_SMALL_FILE_STANDALONE)
      target_add_copy_command(${CJAP_PACKAGE_PROJECT_NAME}_Package "${ICON_SMALL_FILE_STANDALONE}" "${CJAP_PACKAGE_BUILD_PATH}")
      file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "cp -f $ThisPath/icon.png '/opt/${PLUGIN_NAME}/icon.png'\n")
    endif()
    
    file(WRITE "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "[Desktop Entry]\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "Version = ${CJAP_PACKAGE_PROJECT_VERSION}\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "Type = Application\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "Terminal = false\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "Name = ${PLUGIN_NAME}\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "Exec = /usr/bin/'${PLUGIN_NAME}'\n")
    if(ICON_BIG_FILE_STANDALONE OR ICON_SMALL_FILE_STANDALONE)
      file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "Icon = /opt/'${PLUGIN_NAME}'/icon.png\n")
    endif()
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "Categories = Audio;\n")
    target_add_copy_command(${CJAP_PACKAGE_PROJECT_NAME}_Package "${CJAP_PACKAGE_INSTALL_DIR}/${PLUGIN_NAME}.desktop" "${CJAP_PACKAGE_BUILD_PATH}")

    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/install.sh" "cp -f $ThisPath/'${PLUGIN_NAME}.desktop' /usr/share/applications\n")

    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/uninstall.sh" "rm -rf '/opt/${PLUGIN_NAME}'\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/uninstall.sh" "rm -f '/usr/bin/${PLUGIN_NAME}'\n")
    file(APPEND "${CJAP_PACKAGE_INSTALL_DIR}/uninstall.sh" "rm -f '/usr/share/applications/${PLUGIN_NAME}.desktop'\n")
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
  endif()
endfunction(target_enable_linux_cjap_package)


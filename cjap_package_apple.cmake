# - CMake JUCE Audio Plug-in Packaging - Apple
#
# This file contains functions for packaging the plug-ins on Apple MacOS. 

# Internal
set(CJAP_PACKAGE_PACKAGER_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/packager.sh")
set(CJAP_PACKAGE_XML_FILE1_PATH "${CJAP_PACKAGE_BUILD_PATH}/file1.xml")
set(CJAP_PACKAGE_XML_FILE2_PATH "${CJAP_PACKAGE_BUILD_PATH}/file2.xml")
set(CJAP_PACKAGE_XML_FILE3_PATH "${CJAP_PACKAGE_BUILD_PATH}/file3.xml")

# - Prepares the packaging for the target on Apple
#
# The function prepares the scripts for the packaging.
# The packaging requires the iscc porgram. 
if(CJAP_PACKAGE_ENABLED AND APPLE)
  file(MAKE_DIRECTORY ${CJAP_PACKAGE_INSTALL_DIR})
  if(CJAP_CODESIGN_ENABLED)
    set(SIGN_CMD "--sign \"Developer ID Installer\" --timestamp")
  endif()
  file(WRITE "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "#!/bin/sh\n\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "plugin_folder=$1\n\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "build_target_format_pkg()\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "{\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    name=\$1\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    format=\$2\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    source=\$3\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgid=\$4\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgdestination=\$5\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgversion=\"${CJAP_PACKAGE_PROJECT_VERSION}\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgsource=\"${CJAP_PACKAGE_BUILD_PATH}/$format\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgtarget=\"${CJAP_PACKAGE_BUILD_PATH}/$name.pkg\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    \n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    mkdir -p \"$pkgsource\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    cp -r \"$plugin_folder/$format/$source\" \"$pkgsource\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgbuild --analyze --root \"$pkgsource\" \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
  #file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    plutil -replace BundleIsRelocatable -bool NO \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgbuild ${SIGN_CMD} --root \"$pkgsource\" --identifier \"\$pkgid\" --version \"\$pkgversion\" --install-location \"\$pkgdestination\" \"\$pkgtarget\" || exit 1\n")
  if(CJAP_CODESIGN_ENABLED)
    file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgutil --check-signature \$pkgtarget\n")
  endif()
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    rm \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    rm -r \"$pkgsource\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "}\n\n")
  file(CHMOD "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)

  file(WRITE "${CJAP_PACKAGE_XML_FILE1_PATH}" "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
  file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "<installer-gui-script minSpecVersion=\"1\">\n")
  file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <title>${CJAP_PACKAGE_PROJECT_NAME} ${CJAP_PACKAGE_PROJECT_VERSION}</title>\n")
  if(EXISTS ${CJAP_PACKAGE_LICENSE_FILE_PATH})
    file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <license file=\"${CJAP_PACKAGE_LICENSE_FILE_PATH}\"/>\n")
  endif()
  if(EXISTS ${CJAP_PACKAGE_INSTALL_FILE_PATH})
    file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <readme file=\"${CJAP_PACKAGE_INSTALL_FILE_PATH}\"/>\n")
  endif()
  if(EXISTS ${CJAP_PACKAGE_COMPANY_LOGO_PNG_PATH})
    file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <background file=\"${CJAP_PACKAGE_COMPANY_LOGO_PNG_PATH}\"/>\n")
    file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <background alignment=\"bottomleft\"/>\n")
  endif()
  file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <options require-scripts=\"false\" customize=\"always\" hostArchitectures=\"x86_64,arm64\" rootVolumeOnly=\"true\"/>\n")

  file(WRITE "${CJAP_PACKAGE_XML_FILE2_PATH}" "    <choices-outline>\n")
  file(WRITE "${CJAP_PACKAGE_XML_FILE3_PATH}" "    </choices-outline>\n")

  set(CJAP_PACKAGE_XML_END_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/end.xml")
  file(WRITE "${CJAP_PACKAGE_XML_END_FILE_PATH}" "</installer-gui-script>\n")

  set(CJAP_PACKAGE_DISTRIBUTION_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/distribution.xml")

  set(CJAP_PACKAGE_GENERATOR_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/generator.sh")
  file(WRITE "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "#!/bin/sh\n\n")
  file(APPEND "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "${CJAP_PACKAGE_PACKAGER_FILE_PATH} \$1\n")
  file(APPEND "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "cat ${CJAP_PACKAGE_XML_FILE1_PATH} ${CJAP_PACKAGE_XML_FILE2_PATH} ${CJAP_PACKAGE_XML_FILE3_PATH} ${CJAP_PACKAGE_XML_END_FILE_PATH} > ${CJAP_PACKAGE_DISTRIBUTION_FILE_PATH}\n")
  file(APPEND "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "productbuild ${SIGN_CMD} --distribution \"${CJAP_PACKAGE_DISTRIBUTION_FILE_PATH}\" --package-path \"${CJAP_PACKAGE_BUILD_PATH}\" \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\"\n")
  file(CHMOD "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)

  add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Package ALL ${CJAP_PACKAGE_GENERATOR_FILE_PATH} ${CMAKE_CURRENT_BINARY_DIR}/${CJAP_PACKAGE_PROJECT_NAME}_artefacts/$<CONFIG> BYPRODUCTS ${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg)

  if(CJAP_CODESIGN_ENABLED)
    if(CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER STREQUAL "")
      message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_Notarize cannot be generated because CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER is undefined")
    else()
      set(CJAP_PACKAGE_NOTARIZER_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/notarizer.sh")
      file(WRITE "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "#!/bin/sh\n\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "xcrun notarytool submit \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\" --keychain-profile \"${CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER}\" --wait > \"${CJAP_PACKAGE_BUILD_PATH}/notarize.log\" 2>&1\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "notaryid=$(awk '/^  id:/{sub(/^  id:/, \"\"); print; exit}' \"${CJAP_PACKAGE_BUILD_PATH}/notarize.log\")\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "xcrun stapler staple \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\"\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "spctl -a -vvv -t install \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\"\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "xcrun notarytool log \$notaryid --keychain-profile \"${CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER}\" > \"${CJAP_PACKAGE_BUILD_PATH}/info.log\" 2>&1\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "if ! grep -q \"Accepted\" \"${CJAP_PACKAGE_BUILD_PATH}/notarize.log\"; then\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "    echo \"Status: Invalid\"\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "    exit 1\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "else\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "    echo \"Status: Accepted\"\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "fi\n")
      file(CHMOD "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
      add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Notarize ALL COMMAND ${CJAP_PACKAGE_NOTARIZER_FILE_PATH})
      add_dependencies(${CJAP_PACKAGE_PROJECT_NAME}_Notarize ${CJAP_PACKAGE_PROJECT_NAME}_Package)
    endif()
  endif()
endif()

# - Enables the generic packaging for the target on Apple
#
# The function enables the packaging given specific arguments.
# See target_enable_apple_all_package
function(target_enable_apple_generic_package target formattarget format destination)
  if(TARGET ${formattarget})
    get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
    get_target_property(PLUGIN_EXTENSION ${formattarget} BUNDLE_EXTENSION)
    if(NOT PLUGIN_EXTENSION)
      set(PLUGIN_EXTENSION "app")
    endif()
    get_target_property(APP_VERSION ${target} JUCE_VERSION)
    get_target_property(BUNDLE_ID ${target} JUCE_BUNDLE_ID)
    string(REPLACE " " " " PLUGIN_NAME_FORMATED ${PLUGIN_NAME})
    set(PACKAGE_NAME ${PLUGIN_NAME_FORMATED}_${format})
    set(DISPLAY_NAME "${PLUGIN_NAME} ${format}")

    string(TOLOWER ${format} FORMAT_FORMATED)
    string(TOLOWER ${BUNDLE_ID} BUNDLE_ID_FORMATED)
    set(PACKAGE_ID ${BUNDLE_ID_FORMATED}.${FORMAT_FORMATED}.pkg)

    file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "build_target_format_pkg \"${PACKAGE_NAME}\" \"${format}\" \"${PLUGIN_NAME}.${PLUGIN_EXTENSION}\" \"${PACKAGE_ID}\" \"${destination}\"\n")
    file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <pkg-ref id=\"${PACKAGE_ID}\"/>\n")
    file(APPEND "${CJAP_PACKAGE_XML_FILE2_PATH}" "        <line choice=\"${PACKAGE_ID}\"/>\n")
    file(APPEND "${CJAP_PACKAGE_XML_FILE3_PATH}" "    <choice id=\"${PACKAGE_ID}\" visible=\"true\" start_selected=\"true\" title=\"${DISPLAY_NAME}\"><pkg-ref id=\"${PACKAGE_ID}\"/></choice><pkg-ref id=\"${PACKAGE_ID}\" version=\"${APP_VERSION}\" onConclusion=\"none\">${PACKAGE_NAME}.pkg</pkg-ref>\n")

  endif()
endfunction(target_enable_apple_generic_package)

# - Enables packaging for all the formats of the target on Apple
#
# The function enables the packaging for the all formats.
# The VST3 will be installed in the /Library/Audio/Plug-Ins/VST3 directory.
# The VST3 - ARA will be installed in the /Library/Audio/Plug-Ins/ARA directory.
# The AudioUnits will be installed in the /Library/Audio/Plug-Ins/Components directory.
# The AAX will be installed in the /Library/Application Support/Avid/Audio/Plug-Ins directory.
# The Standalone will be installed in the /Applications directory.
function(target_enable_apple_all_package target)
  if(TARGET ${target}_VST3)
    target_enable_apple_generic_package(${target} ${target}_VST3 "VST3" "/Library/Audio/Plug-Ins/VST3")
    get_target_property(IS_ARA_EFFECT ${target} JUCE_IS_ARA_EFFECT)
    if(IS_ARA_EFFECT)
      target_enable_apple_generic_package(${target} ${target}_VST3 "ARA" "/Library/Audio/Plug-Ins/ARA")
    endif()
  endif()
  if(TARGET ${target}_AU)
    target_enable_apple_generic_package(${target} ${target}_AU "AU" "/Library/Audio/Plug-Ins/Components")
  endif()
  if(TARGET ${target}_AAX)
    target_enable_apple_generic_package(${target} ${target}_AAX "AAX" "/Library/Application Support/Avid/Audio/Plug-Ins")
  endif()
  if(TARGET ${target}_Standalone)
    target_enable_apple_generic_package(${target} ${target}_Standalone "Standalone" "/Applications")
  endif()
endfunction(target_enable_apple_all_package)

# - Enables the packaging for the target on Apple
#
# The function enables the packaging for:
# VST3 (ARA), AudioUnits, AAX and Standalone
function(target_enable_apple_cjap_package target)
  if(CJAP_PACKAGE_ENABLED AND APPLE)
    target_enable_apple_all_package(${target})
  endif()
endfunction(target_enable_apple_cjap_package)


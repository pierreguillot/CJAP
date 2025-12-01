# - CMake JUCE Audio Plug-in Packaging - Apple
#
# This file contains functions for packaging the plug-ins on Apple MacOS. 

# Internal
set(CJAP_PACKAGE_PACKAGER_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/packager.sh")
set(CJAP_PACKAGE_XML_FILE1_PATH "${CJAP_PACKAGE_BUILD_PATH}/file1.xml")
set(CJAP_PACKAGE_XML_FILE2_PATH "${CJAP_PACKAGE_BUILD_PATH}/file2.xml")
set(CJAP_PACKAGE_XML_FILE3_PATH "${CJAP_PACKAGE_BUILD_PATH}/file3.xml")

# CMAKE_OSX_ARCHITECTURES is x86_64 but the system is arm64, 
# replace pkgbuild by arch -x86_64 pkgbuild, plutil by arch -x86_64 plutil, and productbuild by arch -x86_64 productbuild
if(CJAP_PACKAGE_ENABLED AND APPLE)
  if(CMAKE_OSX_ARCHITECTURES STREQUAL "x86_64" AND CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
    set(CJAP_PACKAGE_BUILD_CMD_PREFIX "arch -x86_64 ")
  else()
    set(CJAP_PACKAGE_BUILD_CMD_PREFIX "")
  endif()
endif() 

# - Prepares the packaging for the target on Apple
#
# The function prepares the scripts for the packaging.
# The packaging requires the iscc porgram. 
if(CJAP_PACKAGE_ENABLED AND APPLE)
  file(MAKE_DIRECTORY ${CJAP_PACKAGE_INSTALL_DIR})
  if(CJAP_CODESIGN_ENABLED)
    set(SIGN_CMD "--sign \"${CJAP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT}\" --timestamp ")
  endif()
  file(WRITE "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "#!/bin/sh\n\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "configuration=$1\n\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "build_target_pkg()\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "{\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    name=\$1\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgid=\$2\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgversion=\"${CJAP_PACKAGE_PROJECT_VERSION}\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgdir=\"${CJAP_PACKAGE_BUILD_PATH}/$name\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgtarget=\"${CJAP_PACKAGE_BUILD_PATH}/$name.pkg\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    mkdir -p \"$pkgdir\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    ${CJAP_PACKAGE_BUILD_CMD_PREFIX}pkgbuild --analyze --nopayload --root \"$pkgdir\" \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    ${CJAP_PACKAGE_BUILD_CMD_PREFIX}pkgbuild --nopayload --component-plist \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\" --root \"$pkgdir\" --identifier \"\$pkgid\" --version \"\$pkgversion\" \"\$pkgtarget\" || exit 1\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    rm -r \"$pkgdir\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    rm \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "}\n\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "build_target_format_pkg()\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "{\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    name=\$1\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    sourcedir=\$2\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    sourcename=\$3\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgid=\$4\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgdestination=\$5\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    extraargs=\$6\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgversion=\"${CJAP_PACKAGE_PROJECT_VERSION}\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgdir=\"${CJAP_PACKAGE_BUILD_PATH}/$name\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgtarget=\"${CJAP_PACKAGE_BUILD_PATH}/$name.pkg\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    \n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    mkdir -p \"$pkgdir\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    cp -r \"$sourcedir/$sourcename\" \"$pkgdir\"\n")
  if(CJAP_CODESIGN_ENABLED)
    file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    \"${CJAP_CODESIGN_SIGNATOR_FILE_PATH}\" \"$pkgdir/$sourcename\"\n")
  endif()
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    ${CJAP_PACKAGE_BUILD_CMD_PREFIX}pkgbuild --analyze --root \"$pkgdir\" \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    plutil -replace BundleIsRelocatable -bool NO \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    ${CJAP_PACKAGE_BUILD_CMD_PREFIX}pkgbuild $extraargs ${SIGN_CMD}--component-plist \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\" --root \"$pkgdir\" --identifier \"\$pkgid\" --version \"\$pkgversion\" --install-location \"\$pkgdestination\" \"\$pkgtarget\" || exit 1\n")
  if(CJAP_CODESIGN_ENABLED)
    file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    pkgutil --check-signature \"\$pkgtarget\"\n")
  endif()
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    rm -r \"$pkgdir\"\n")
  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "    rm \"${CJAP_PACKAGE_BUILD_PATH}/$name.plist\"\n")
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

  set(CJAP_PACKAGE_DISTRIBUTION_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/distribution.dist")

  set(CJAP_PACKAGE_GENERATOR_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/generator.sh")
  file(WRITE "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "#!/bin/sh\n\n")
  file(APPEND "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "${CJAP_PACKAGE_PACKAGER_FILE_PATH} \$1\n")
  file(APPEND "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "cat ${CJAP_PACKAGE_XML_FILE1_PATH} ${CJAP_PACKAGE_XML_FILE2_PATH} ${CJAP_PACKAGE_XML_FILE3_PATH} ${CJAP_PACKAGE_XML_END_FILE_PATH} > ${CJAP_PACKAGE_DISTRIBUTION_FILE_PATH}\n")
  file(APPEND "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" "${CJAP_PACKAGE_BUILD_CMD_PREFIX}productbuild ${SIGN_CMD}--distribution \"${CJAP_PACKAGE_DISTRIBUTION_FILE_PATH}\" --package-path \"${CJAP_PACKAGE_BUILD_PATH}\" \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\"\n")
  file(CHMOD "${CJAP_PACKAGE_GENERATOR_FILE_PATH}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)

  add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Package ALL ${CJAP_PACKAGE_GENERATOR_FILE_PATH} $<CONFIG> BYPRODUCTS ${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg)
  if(TARGET ${CJAP_CODESIGN_PROJECT_NAME}_CodeSign)
      add_dependencies(${CJAP_PACKAGE_PROJECT_NAME}_Package ${CJAP_CODESIGN_PROJECT_NAME}_CodeSign)
  endif()

  if(CJAP_CODESIGN_ENABLED)
    if(CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER STREQUAL "")
      message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_Notarize cannot be generated because CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER is undefined")
    else()
      set(CJAP_PACKAGE_NOTARIZER_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/notarizer.sh")
      file(WRITE "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "#!/bin/sh\n\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "xcrun notarytool submit \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\" --keychain-profile \"${CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER}\" --wait > \"${CJAP_PACKAGE_BUILD_PATH}/notarize.log\" 2>&1\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "cat \"${CJAP_PACKAGE_BUILD_PATH}/notarize.log\"\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "notaryid=$(awk '/^  id:/{sub(/^  id:/, \"\"); print; exit}' \"${CJAP_PACKAGE_BUILD_PATH}/notarize.log\")\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "xcrun notarytool log \$notaryid --keychain-profile \"${CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER}\" > \"${CJAP_PACKAGE_BUILD_PATH}/info.log\" 2>&1\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "cat \"${CJAP_PACKAGE_BUILD_PATH}/info.log\"\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "xcrun stapler staple \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\" || { exit 1; }\n")
      file(APPEND "${CJAP_PACKAGE_NOTARIZER_FILE_PATH}" "spctl -a -vvv -t install \"${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}.pkg\" || { exit 1; }\n")
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
function(target_enable_apple_generic_package target tformat format destination)
  if(TARGET ${target}_${tformat})
    get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
    get_target_property(PLUGIN_EXTENSION ${target}_${tformat} BUNDLE_EXTENSION)
    get_target_property(PLUGIN_OUTPUT_DIRECTORY ${target} LIBRARY_OUTPUT_DIRECTORY)
    get_target_property(PLUGIN_VERSION ${target} JUCE_VERSION)
    get_target_property(PLUGIN_ID ${target} JUCE_BUNDLE_ID)
    get_target_property(PACKAGE_EXTRA_ARGS ${target} CJAP_PACKAGE_EXTRA_ARGS)

    string(REPLACE "$<CONFIG>" "$configuration" PLUGIN_OUTPUT_DIRECTORY ${PLUGIN_OUTPUT_DIRECTORY})
    if(NOT PLUGIN_EXTENSION)
      set(PLUGIN_EXTENSION "app")
    endif()
    string(REPLACE " " "_" PACKAGE_NAME ${PLUGIN_NAME}_${format})
    string(TOLOWER ${PLUGIN_ID}.${format}.pkg PACKAGE_ID)
    string(REPLACE " " "" PACKAGE_ID ${PACKAGE_ID})
    set(PLUGIN_DESCRIPTION "The ${PLUGIN_NAME} plugin in ${format} format that will be installed in '${destination}'.")
    set(PLUGIN_ARTEFACT_DIR "${PLUGIN_OUTPUT_DIRECTORY}/${tformat}")
    set(PLUGIN_ARTEFACT_FILE "${PLUGIN_NAME}.${PLUGIN_EXTENSION}")

    if(NOT PACKAGE_EXTRA_ARGS)
      set(PACKAGE_EXTRA_ARGS "")
    endif()
    
    file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "build_target_format_pkg \"${PACKAGE_NAME}\" \"${PLUGIN_ARTEFACT_DIR}\" \"${PLUGIN_ARTEFACT_FILE}\" \"${PACKAGE_ID}\" \"${destination}\" \"${PACKAGE_EXTRA_ARGS}\"\n")
    file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <pkg-ref id=\"${PACKAGE_ID}\"/>\n")
    file(APPEND "${CJAP_PACKAGE_XML_FILE2_PATH}" "            <line choice=\"${PACKAGE_ID}\"/>\n")
    file(APPEND "${CJAP_PACKAGE_XML_FILE3_PATH}" "    <choice id=\"${PACKAGE_ID}\" visible=\"true\" start_selected=\"true\" title=\"${format}\" description=\"${PLUGIN_DESCRIPTION}\"><pkg-ref id=\"${PACKAGE_ID}\"/></choice><pkg-ref id=\"${PACKAGE_ID}\" version=\"${PLUGIN_VERSION}\" onConclusion=\"none\">${PACKAGE_NAME}.pkg</pkg-ref>\n")
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

  get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
  get_target_property(PLUGIN_ID ${target} JUCE_BUNDLE_ID)
  get_target_property(PLUGIN_VERSION ${target} JUCE_VERSION)
  get_target_property(PLUGIN_DESCRIPTION ${target} JUCE_DESCRIPTION)
  string(REPLACE " " "_" PACKAGE_NAME ${PLUGIN_NAME})
  string(TOLOWER ${PLUGIN_ID}.pkg PACKAGE_ID)

  file(APPEND "${CJAP_PACKAGE_PACKAGER_FILE_PATH}" "build_target_pkg \"${PACKAGE_NAME}\" \"${PACKAGE_ID}\"\n")
  file(APPEND "${CJAP_PACKAGE_XML_FILE1_PATH}" "    <pkg-ref id=\"${PACKAGE_ID}\"/>\n")
  file(APPEND "${CJAP_PACKAGE_XML_FILE2_PATH}" "        <line choice=\"${PACKAGE_ID}\">\n")
  file(APPEND "${CJAP_PACKAGE_XML_FILE3_PATH}" "    <choice id=\"${PACKAGE_ID}\" visible=\"true\" start_selected=\"true\" title=\"${PLUGIN_NAME}\" description=\"${PLUGIN_DESCRIPTION}\"><pkg-ref id=\"${PACKAGE_ID}\"/></choice><pkg-ref id=\"${PACKAGE_ID}\" version=\"${PLUGIN_VERSION}\" onConclusion=\"none\">${PACKAGE_NAME}.pkg</pkg-ref>\n")
  
  if(TARGET ${target}_VST3)
    target_enable_apple_generic_package(${target} "VST3" "VST3" "/Library/Audio/Plug-Ins/VST3")
    get_target_property(IS_ARA_EFFECT ${target} JUCE_IS_ARA_EFFECT)
    if(IS_ARA_EFFECT)
      target_enable_apple_generic_package(${target} "VST3" "ARA" "/Library/Audio/Plug-Ins/ARA")
    endif()
  endif()
  if(TARGET ${target}_AU)
    target_enable_apple_generic_package(${target} "AU" "Audio Unit" "/Library/Audio/Plug-Ins/Components")
  endif()
  if(TARGET ${target}_AAX)
    target_enable_apple_generic_package(${target} "AAX" "AAX" "/Library/Application Support/Avid/Audio/Plug-Ins")
  endif()
  if(TARGET ${target}_Standalone)
    target_enable_apple_generic_package(${target} "Standalone" "Standalone" "/Applications")
  endif()
  file(APPEND "${CJAP_PACKAGE_XML_FILE2_PATH}" "        </line>\n")
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

# - Adds a file to the MacOS package
#
# The function adds a file to install with the package.
function(apple_cjap_package_add_file file destination version visible)
  if(CJAP_PACKAGE_ENABLED AND APPLE)
    get_filename_component(file_name ${file} NAME)
    get_filename_component(file_name_we ${file} NAME_WE)
    string(REPLACE " " "_" file_name_we ${file_name_we})
    string(TOLOWER "com.${CJAP_PACKAGE_COMPANY_NAME}.${file_name}.${CJAP_PACKAGE_PROJECT_NAME}.pkg" CJAP_FILE_PACKAGE_UID)
    if(visible)
      set(VISIBILITY "true")
    else()
      set(VISIBILITY "false")
    endif()

    file(MAKE_DIRECTORY ${CJAP_PACKAGE_BUILD_PATH}/${file_name_we})
    file(COPY ${file} DESTINATION ${CJAP_PACKAGE_BUILD_PATH}/${file_name_we})
    
    file(APPEND ${CJAP_PACKAGE_XML_FILE1_PATH} "    <pkg-ref id=\"${CJAP_FILE_PACKAGE_UID}\"/>\n")
    file(APPEND ${CJAP_PACKAGE_XML_FILE2_PATH} "        <line choice=\"${CJAP_FILE_PACKAGE_UID}\"/>\n")
    file(APPEND ${CJAP_PACKAGE_XML_FILE3_PATH} "    <choice id=\"${CJAP_FILE_PACKAGE_UID}\" visible=\"${VISIBILITY}\" start_selected=\"true\" title=\"${file_name}\"><pkg-ref id=\"${CJAP_FILE_PACKAGE_UID}\"/></choice><pkg-ref id=\"${CJAP_FILE_PACKAGE_UID}\" version=\"${version}\" onConclusion=\"none\">${file_name}.pkg</pkg-ref>\n")

    set(CJAP_PACKAGE_FILE_SCRIT "${CJAP_PACKAGE_BUILD_PATH}/${file_name_we}.sh")
    file(WRITE ${CJAP_PACKAGE_FILE_SCRIT} "#!/bin/sh\n\n")
    file(CHMOD ${CJAP_PACKAGE_FILE_SCRIT} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    if(CJAP_CODESIGN_ENABLED)
      file(APPEND ${CJAP_PACKAGE_FILE_SCRIT} "codesign --sign \"${CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT}\" -f -o runtime --timestamp \"${CJAP_PACKAGE_BUILD_PATH}/${file_name_we}/${file_name}\"\n")
      file(APPEND ${CJAP_PACKAGE_FILE_SCRIT} "${CJAP_PACKAGE_BUILD_CMD_PREFIX}pkgbuild --sign \"${CJAP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT}\" --timestamp --root \"${CJAP_PACKAGE_BUILD_PATH}/${file_name_we}\" --identifier \"${CJAP_FILE_PACKAGE_UID}\" --version \"${version}\" --install-location \"${destination}/\" \"${CJAP_PACKAGE_BUILD_PATH}/${file_name}.pkg\"\n")
      file(APPEND ${CJAP_PACKAGE_FILE_SCRIT} "pkgutil --check-signature \"${CJAP_PACKAGE_BUILD_PATH}/${file_name}.pkg\"\n")
    else()
      file(APPEND ${CJAP_PACKAGE_FILE_SCRIT} "${CJAP_PACKAGE_BUILD_CMD_PREFIX}pkgbuild --root \"${CJAP_PACKAGE_BUILD_PATH}/${file_name_we}\" --identifier \"${CJAP_FILE_PACKAGE_UID}\" --version \"${version}\" --install-location \"${destination}/\" \"${CJAP_PACKAGE_BUILD_PATH}/${file_name}.pkg\"\n")
    endif()
    add_custom_target(${file_name_we}_Package COMMAND ${CJAP_PACKAGE_FILE_SCRIT})

    add_dependencies(${CJAP_PACKAGE_PROJECT_NAME}_Package ${file_name_we}_Package)
  endif()
endfunction(apple_cjap_package_add_file)

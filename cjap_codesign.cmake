# - CMake JUCE Audio Plug-in Code-Signing
#
# This file contains functions to code-sign the plug-ins. 
# ToDo: Add an option to use deep code-signing

# Options for enabling the the code-signing.
option(CJAP_CODESIGN_ENABLED "Enable the plug-in code-signing" OFF)

# The variables to sign AAX plug-ins
set(CJAP_CODESIGN_WINDOWS_KEYFILE "" CACHE PATH "The Windows (.p12) certificate file")
set(CJAP_CODESIGN_WINDOWS_KEYPASSWORD "" CACHE STRING "The password of the Windows (.p12 and .pfx) certificate files")
set(CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT "Developer ID Application" CACHE STRING "The Apple Developer ID Application certificate")
set(CJAP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT "Developer ID Installer" CACHE STRING "The Apple Developer ID Installer certificate")
set(CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER "notary-installer" CACHE STRING "The Apple keychain profile for installer")
set(CJAP_CODESIGN_PACE_EMAIL "" CACHE STRING "The PACE developer email")
set(CJAP_CODESIGN_PACE_WCGUID "" CACHE STRING "The PACE GUID")
set(CJAP_CODESIGN_TIMESTAMP_SERVER "http://timestamp.sectigo.com" CACHE STRING "The timestamp server to sign packages on Windows")

# Internal
set(CJAP_CODESIGN_BUILD_PATH "${CMAKE_CURRENT_BINARY_DIR}/Sign")
set(CJAP_CODESIGN_SIGNATOR_FILE_PATH "${CJAP_CODESIGN_BUILD_PATH}/signator.sh")
set(CJAP_CODESIGN_WINDOWS_CERTFILE "${CJAP_CODESIGN_BUILD_PATH}/cert.pfx")

# - Searchs for a valid Apple developer certificate 
#
# The code searchs a valid Apple developer certificate and 
# intializes the signing attributes.
if(CJAP_CODESIGN_ENABLED AND APPLE)
  execute_process(COMMAND security find-certificate -c ${CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT} OUTPUT_VARIABLE CERTIFICATE_RESULT ERROR_VARIABLE CERTIFICATE_ERROR)
  if(CERTIFICATE_RESULT)
    message(STATUS "Apple ${CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT} Certificate is found")
  else()
    message(WARNING "Apple ${CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT} Certificate cannot be found")
    set(CJAP_CODESIGN_ENABLED OFF)
  endif()

  if(CJAP_PACKAGE_ENABLED)
    execute_process(COMMAND security find-certificate -c ${CJAP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT} OUTPUT_VARIABLE CERTIFICATE_RESULT ERROR_VARIABLE CERTIFICATE_ERROR)
    if(CERTIFICATE_RESULT)
      message(STATUS "Apple ${CJAP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT} Certificate is found")
    else()
      message(WARNING "Apple ${CJAP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT} Certificate cannot be found")
      set(CJAP_CODESIGN_ENABLED OFF)
    endif()
  endif()

  set(CMAKE_XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME TRUE CACHE BOOL "")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_INJECT_BASE_ENTITLEMENTS "$<$<CONFIG:Debug>:YES>")
endif()

# - Searchs the wraptool program
#
# The code searchs for wraptool on the system. If the program cannot be
# found and the PACE code-signing variables are defined, the code 
# generates a warning.
if(CJAP_CODESIGN_ENABLED)
  if(APPLE)
    if(NOT CJAP_CODESIGN_PACE_EMAIL STREQUAL "" AND NOT CJAP_CODESIGN_PACE_WCGUID STREQUAL "")
      find_program(CJAP_CODESIGN_WRAPTOOL_EXE "wraptool" PATH "/Applications/PACEAntiPiracy/Eden/Fusion/Current/bin/")
      if(CJAP_CODESIGN_WRAPTOOL_EXE)
        message(STATUS "AAX Plugins code-signing available ${CJAP_CODESIGN_WRAPTOOL_EXE}")
      endif()
    endif()

    file(WRITE "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "#!/bin/sh\n\n")
    if(CJAP_CODESIGN_WRAPTOOL_EXE)
      file(APPEND "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "if [[ \"$1\" == *.aaxplugin* ]]; then\n")
      file(APPEND "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "  ${CJAP_CODESIGN_WRAPTOOL_EXE} sign --verbose --account ${CJAP_CODESIGN_PACE_EMAIL} --signid \"${CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT}\" --wcguid ${CJAP_CODESIGN_PACE_WCGUID} --in \"\$1\"\n")
      file(APPEND "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "else\n")
      file(APPEND "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "  codesign --sign \"${CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT}\" --deep -f -o runtime --timestamp -v \"\$1\"\n")
      file(APPEND "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "fi\n")
    else()
      file(APPEND "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "codesign --sign \"${CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT}\" --deep -f -o runtime --timestamp -v \"\$1\"\n")
    endif()
    file(APPEND "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" "codesign -dvv \"\$1\"\n")
    file(CHMOD "${CJAP_CODESIGN_SIGNATOR_FILE_PATH}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)

  elseif(WIN32)
    if(NOT CJAP_CODESIGN_PACE_EMAIL STREQUAL "" AND NOT CJAP_CODESIGN_PACE_WCGUID STREQUAL "")
      find_program(CJAP_CODESIGN_WRAPTOOL_EXE "wraptool")
      if(CJAP_CODESIGN_WRAPTOOL_EXE)
        message(STATUS "AAX Plugins code-signing available with ${CJAP_CODESIGN_WRAPTOOL_EXE}")
      endif()
    endif()

    if(CJAP_CODESIGN_WINDOWS_KEYFILE)
      file(MAKE_DIRECTORY ${CJAP_CODESIGN_BUILD_PATH})
      file(COPY_FILE ${CJAP_CODESIGN_WINDOWS_KEYFILE} ${CJAP_CODESIGN_WINDOWS_CERTFILE})
    endif()
  endif()
endif()

# - Enables the code-signing for the target
#
# The function enables the code-signing for:
# VST3, AudioUnits, AAX
function(target_enable_cjap_codesign target)
  if(APPLE AND CJAP_CODESIGN_ENABLED AND TARGET ${target}_AU)
    get_target_property(ARTEFACT_FILE_AU ${target}_AU JUCE_PLUGIN_ARTEFACT_FILE)
    add_custom_command(TARGET ${target}_AU POST_BUILD COMMAND ${CJAP_CODESIGN_SIGNATOR_FILE_PATH} "${ARTEFACT_FILE_AU}" VERBATIM)
    set_target_properties(${target}_AU PROPERTIES XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES)
    set_target_properties(${target}_AU PROPERTIES XCODE_ATTRIBUTE_CODE_SIGN_INJECT_BASE_ENTITLEMENTS "$<$<CONFIG:Debug>:YES>")
  endif()

  if(APPLE AND CJAP_CODESIGN_ENABLED AND TARGET ${target}_VST3)
    get_target_property(ARTEFACT_FILE_VST3 ${target}_VST3 JUCE_PLUGIN_ARTEFACT_FILE)
    add_custom_command(TARGET ${target}_VST3 POST_BUILD COMMAND ${CJAP_CODESIGN_SIGNATOR_FILE_PATH} "${ARTEFACT_FILE_VST3}" VERBATIM)
    set_target_properties(${target}_VST3 PROPERTIES XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES)
    set_target_properties(${target}_VST3 PROPERTIES XCODE_ATTRIBUTE_CODE_SIGN_INJECT_BASE_ENTITLEMENTS "$<$<CONFIG:Debug>:YES>")
  endif()

  if(APPLE AND CJAP_CODESIGN_ENABLED AND TARGET ${target}_Standalone)
    get_target_property(ARTEFACT_FILE_Standalone ${target}_Standalone JUCE_PLUGIN_ARTEFACT_FILE)
    add_custom_command(TARGET ${target}_Standalone POST_BUILD COMMAND ${CJAP_CODESIGN_SIGNATOR_FILE_PATH} "${ARTEFACT_FILE_Standalone}" VERBATIM)
    set_target_properties(${target}_Standalone PROPERTIES XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES)
    set_target_properties(${target}_Standalone PROPERTIES XCODE_ATTRIBUTE_CODE_SIGN_INJECT_BASE_ENTITLEMENTS "$<$<CONFIG:Debug>:YES>")
  endif()

  if(CJAP_CODESIGN_ENABLED AND TARGET ${target}_AAX)
    if(APPLE)
      if(CJAP_CODESIGN_WRAPTOOL_EXE)
        get_target_property(ARTEFACT_FILE_AAX ${target}_AAX JUCE_PLUGIN_ARTEFACT_FILE)
        add_custom_command(TARGET ${target}_AAX POST_BUILD COMMAND ${CJAP_CODESIGN_SIGNATOR_FILE_PATH} "${ARTEFACT_FILE_AAX}" VERBATIM)
        set_target_properties(${target}_AAX PROPERTIES XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES)
        set_target_properties(${target}_AAX PROPERTIES XCODE_ATTRIBUTE_CODE_SIGN_INJECT_BASE_ENTITLEMENTS "$<$<CONFIG:Debug>:YES>")
      else()
        message(WARNING "AAX Plugins code-signing: wraptool is not available. Please, ensure wraptool is installed and CJAP_CODESIGN_PACE_EMAIL and CJAP_CODESIGN_PACE_WCGUID are defined.")
      endif()
    elseif(WIN32)
      if(CJAP_CODESIGN_WRAPTOOL_EXE)
        get_target_property(ARTEFACT_FILE_AAX ${target}_AAX JUCE_PLUGIN_ARTEFACT_FILE)
        add_custom_command(TARGET ${target}_AAX POST_BUILD COMMAND ${CJAP_CODESIGN_WRAPTOOL_EXE} sign --verbose --account ${CJAP_CODESIGN_PACE_EMAIL} --keyfile ${CJAP_CODESIGN_WINDOWS_KEYFILE} --keypassword ${CJAP_CODESIGN_WINDOWS_KEYPASSWORD} --wcguid ${CJAP_CODESIGN_PACE_WCGUID} --in "${ARTEFACT_FILE_AAX}" VERBATIM)
      else()
        message(WARNING "AAX Plugins code-signing: wraptool is not available. Please, ensure wraptool is installed and CJAP_CODESIGN_PACE_EMAIL and CJAP_CODESIGN_PACE_WCGUID are defined.")
      endif()
    endif()
  endif()
endfunction(target_enable_cjap_codesign)


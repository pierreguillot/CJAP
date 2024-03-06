# - CMake JUCE Audio Plug-in Packaging - Windows
#
# This file contains functions for packaging the plug-ins on Windows. 

# Internal
set(CJAP_PACKAGE_ISS_FILE_PATH "${CJAP_PACKAGE_BUILD_PATH}/Installer.iss")

# - Prepares the packaging for the target on Windows
#
# The function prepares the scripts for the packaging.
# The packaging requires the iscc porgram. 
if(CJAP_PACKAGE_ENABLED AND WIN32)
  set(PLUGIN_REFERENCE_FOLDER "${CMAKE_CURRENT_BINARY_DIR}/${CJAP_PACKAGE_PROJECT_NAME}_artefacts/$<CONFIG>")
  find_program(ISCC_EXE "iscc" HINTS "C:/Program Files (x86)/Inno Setup 6")
  if(ISCC_EXE)
    add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Package ALL ${ISCC_EXE} /DMyRefDir=${PLUGIN_REFERENCE_FOLDER} /O${CJAP_PACKAGE_INSTALL_DIR} ${CJAP_PACKAGE_ISS_FILE_PATH})

    file(WRITE "${CJAP_PACKAGE_ISS_FILE_PATH}" "\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "#define MyAppName \"${CJAP_PACKAGE_PROJECT_NAME}\"\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "#define MyAppVersionName \"${CJAP_PACKAGE_PROJECT_VERSION}\"\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "#define MyAppPublisher \"${CJAP_PACKAGE_COMPANY_NAME}\"\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "#define MyAppURL \"${CJAP_PACKAGE_COMPANY_WEBSITE}\"\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "[Setup]\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "AppId={{${CJAP_PACKAGE_WINDOWS_APP_ID}}}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "AppName={#MyAppName}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "AppVerName={#MyAppName} {#MyAppVersionName}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "AppPublisher={#MyAppPublisher}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "AppPublisherURL={#MyAppURL}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "AppSupportURL={#MyAppURL}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "AppUpdatesURL={#MyAppURL}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "DefaultDirName={commoncf64}\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "DisableProgramGroupPage=yes\n")
    if(EXISTS ${CJAP_PACKAGE_INSTALL_FILE_PATH})
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "InfoBeforeFile=${CJAP_PACKAGE_INSTALL_FILE_PATH}\n")
    endif()
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "OutputBaseFilename={#MyAppName}-install\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Compression=lzma\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "SolidCompression=yes\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "WizardStyle=modern\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "DisableDirPage=yes\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Uninstallable=no\n")
    if(EXISTS ${CJAP_PACKAGE_COMPANY_LOGO_BMP_PATH})
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "WizardImageFile=${CJAP_PACKAGE_COMPANY_LOGO_BMP_PATH}\n")
    endif()
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "[Languages]\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Name: \"english\"; MessagesFile: \"compiler:Default.isl\"\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "[Files]\n")
  else()
    message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_Package cannot be generated because ISCC.exe is not found")
  endif()

  if(CJAP_CODESIGN_ENABLED AND EXISTS ${CJAP_CODESIGN_WINDOWS_CERTFILE})
    if(NOT EXISTS ${CJAP_CODESIGN_WINDOWS_CERTFILE})
      message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_Sign cannot be generated because CJAP_CODESIGN_WINDOWS_CERTFILE is undefined")
    else()
      find_program(SIGNTOOL_EXE "signtool" HINTS "C:/Program Files (x86)/Windows Kits/10/bin/10.0.19041.0/x64")
      if(SIGNTOOL_EXE)
        add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Sign ALL
        COMMAND ${SIGNTOOL_EXE} sign /f "${CJAP_CODESIGN_WINDOWS_CERTFILE}" /p "${CJAP_CODESIGN_WINDOWS_KEYPASSWORD}" /fd SHA256 /td SHA256 /tr ${CJAP_CODESIGN_TIMESTAMP_SERVER} ${CMAKE_CURRENT_BINARY_DIR}/${CJAP_PACKAGE_PROJECT_NAME}-install.exe
        COMMAND ${SIGNTOOL_EXE} verify /pa ${CMAKE_CURRENT_BINARY_DIR}/${CJAP_PACKAGE_PROJECT_NAME}-install.exe
        )
        add_dependencies(${CJAP_PACKAGE_PROJECT_NAME}_Sign ${CJAP_PACKAGE_PROJECT_NAME}_Package)
      else()
        message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_Sign cannot be generated because signtool.exe is not found")
      endif()
    endif()
  endif()
endif()

# - Enables the packaging for the target on Windows
#
# The function enables the packaging for:
# VST3, AAX and Standalone
function(target_enable_windows_cjap_package target)
  if(CJAP_PACKAGE_ENABLED AND WIN32)
    get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
    if(TARGET ${target}_VST3)
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Source: \"{#MyRefDir}\\VST3\\${PLUGIN_NAME}.vst3\\*\"; DestDir: \"{commoncf64}\\VST3\\${PLUGIN_NAME}.vst3\"; Flags: recursesubdirs ignoreversion\n")
    endif()
    if(TARGET ${target}_AAX)
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Source: \"{#MyRefDir}\\AAX\\${PLUGIN_NAME}.aaxplugin\\*\"; DestDir: \"{commoncf64}\\Avid\\Audio\\Plug-Ins\\${PLUGIN_NAME}.aaxplugin\"; Flags: recursesubdirs ignoreversion\n")
    endif()
    if(TARGET ${target}_Standalone)
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Source: \"{#MyRefDir}\\Standalone\\${PLUGIN_NAME}.exe\"; DestDir: \"{app}\"; Flags: ignoreversion\n")
    endif()
  endif()
endfunction(target_enable_windows_cjap_package)


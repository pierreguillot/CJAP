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
  find_program(ISCC_EXE "iscc" HINTS "$ENV{ProgramFiles\(x86\)}/Inno Setup 6")
  if(ISCC_EXE)
    add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_Package ALL ${ISCC_EXE} /DMyConfig=$<CONFIG> /O${CJAP_PACKAGE_INSTALL_DIR} ${CJAP_PACKAGE_ISS_FILE_PATH})

    if(TARGET ${CJAP_CODESIGN_PROJECT_NAME}_CodeSign)
      add_dependencies(${CJAP_PACKAGE_PROJECT_NAME}_Package ${CJAP_CODESIGN_PROJECT_NAME}_CodeSign)
    endif()
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
    if(DEFINED CJAP_PACKAGE_EXTRA_ARGS)
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "\n${CJAP_PACKAGE_EXTRA_ARGS}\n")
    endif()
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "\n")
    file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "[Files]\n")
  else()
    message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_Package cannot be generated because ISCC.exe is not found")
  endif()

  if(CJAP_CODESIGN_ENABLED)
    if(NOT EXISTS ${CJAP_CODESIGN_WINDOWS_CERTFILE})
      message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_SignPackage cannot be generated because the Windows (.pfx) certificate file doesn't exist")
    else()
      find_program(SIGNTOOL_EXE "signtool" HINTS "C:/Program Files (x86)/Windows Kits/10/bin/10.0.19041.0/x64")
      if(SIGNTOOL_EXE)
        add_custom_target(${CJAP_PACKAGE_PROJECT_NAME}_SignPackage ALL
        COMMAND ${SIGNTOOL_EXE} sign /f "${CJAP_CODESIGN_WINDOWS_CERTFILE}" /p "${CJAP_CODESIGN_WINDOWS_KEYPASSWORD}" /fd SHA256 /td SHA256 /tr ${CJAP_CODESIGN_TIMESTAMP_SERVER} ${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}-install.exe
        COMMAND ${SIGNTOOL_EXE} verify /pa ${CJAP_PACKAGE_INSTALL_DIR}/${CJAP_PACKAGE_PROJECT_NAME}-install.exe
        )
        add_dependencies(${CJAP_PACKAGE_PROJECT_NAME}_SignPackage ${CJAP_PACKAGE_PROJECT_NAME}_Package)
      else()
        message(WARNING "${CJAP_PACKAGE_PROJECT_NAME}_SignPackage cannot be generated because signtool.exe is not found")
      endif()
    endif()
  endif()
endif()

# - Enables the generic packaging for the target on Windows
#
# The function enables the packaging given specific arguments.
# See target_enable_windows_all_package
function(target_enable_windows_generic_package target format destination)
  if(TARGET ${target}_${format})
    get_target_property(PLUGIN_NAME ${target} JUCE_PLUGIN_NAME)
    get_target_property(PLUGIN_OUTPUT_DIRECTORY ${target} LIBRARY_OUTPUT_DIRECTORY)
    string(REPLACE "$<CONFIG>" "{#MyConfig}" PLUGIN_OUTPUT_DIRECTORY ${PLUGIN_OUTPUT_DIRECTORY})
    get_target_property(PLUGIN_IS_BUNDLE ${target}_${format} BUNDLE)
    if(PLUGIN_IS_BUNDLE)
      get_target_property(PLUGIN_EXTENSION ${target}_${format} BUNDLE_EXTENSION)
      set(PLUGIN_ARTEFACT_FILE "${PLUGIN_OUTPUT_DIRECTORY}\\${format}\\${PLUGIN_NAME}.${PLUGIN_EXTENSION}")
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Source: \"${PLUGIN_ARTEFACT_FILE}\\*\"; DestDir: \"${destination}\\${PLUGIN_NAME}.${PLUGIN_EXTENSION}\"; Flags: recursesubdirs ignoreversion\n")
    else()
      set(PLUGIN_ARTEFACT_FILE "${PLUGIN_OUTPUT_DIRECTORY}\\${format}\\${PLUGIN_NAME}.exe")
      file(APPEND "${CJAP_PACKAGE_ISS_FILE_PATH}" "Source: \"${PLUGIN_ARTEFACT_FILE}\"; DestDir: \"${destination}\"; Flags: recursesubdirs ignoreversion\n")
    endif()
  endif()
endfunction(target_enable_windows_generic_package)

# - Enables packaging for all the formats of the target on Apple
#
# The function enables the packaging for the all formats.
# The VST3 will be installed in the {commoncf64}\VST3 directory.
# The VST3 - ARA will be installed in the{commoncf64}\ARA directory.
# The AAX will be installed in the {commoncf64}\Avid\Audio\Plug-Ins directory.
# The Standalone will be installed in the {app} directory.
function(target_enable_windows_all_package target)
  if(TARGET ${target}_VST3)
  target_enable_windows_generic_package(${target} "VST3" "{commoncf64}\\VST3")
    get_target_property(IS_ARA_EFFECT ${target} JUCE_IS_ARA_EFFECT)
    if(IS_ARA_EFFECT)
      target_enable_windows_generic_package(${target} "VST3" "{commoncf64}\\ARA")
    endif()
  endif()
  if(TARGET ${target}_AAX)
    target_enable_windows_generic_package(${target} "AAX" "{commoncf64}\\Avid\\Audio\\Plug-Ins")
  endif()
  if(TARGET ${target}_Standalone)
    target_enable_windows_generic_package(${target} "Standalone" "{app}")
  endif()
endfunction(target_enable_windows_all_package)

# - Enables the packaging for the target on Windows
#
# The function enables the packaging for:
# VST3, AAX and Standalone
function(target_enable_windows_cjap_package target)
  if(CJAP_PACKAGE_ENABLED AND WIN32)
    target_enable_windows_all_package(${target})
  endif()
endfunction(target_enable_windows_cjap_package)


# - Adds a file to the Windows package
#
# The function adds a file to install with the package.
function(windows_cjap_package_add_file file destination)
  if(CJAP_PACKAGE_ENABLED AND WIN32)
    cmake_path(NATIVE_PATH file file_native_path)
    file(APPEND ${CJAP_PACKAGE_ISS_FILE_PATH} "Source: \"${file_native_path}\"; DestDir: \"${destination}\"; Flags: ignoreversion\n")
  endif()
endfunction(windows_cjap_package_add_file)

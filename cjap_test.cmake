# - CMake JUCE Audio Plug-in Test
#
# This file contains functions that generate tests for
# the plug-ins. 
# ToDo: Add AAX validator on Windows
# ToDo: Download ARA SDK if necessary
# ToDo: Improve download of VST3 SDK (can use Fetch)

enable_testing()

# Options for defining the tests generated and their level.
option(CJAP_TEST_ENABLED "Enable the all tests the tests" ON)
option(CJAP_TEST_PLUGINVAL_ENABLED "Enable the test using pluginval" ${CJAP_TEST_ENABLED})
option(CJAP_TEST_AUVAL_ENABLED "Enable the test using auval (macOS only)" ${CJAP_TEST_ENABLED})
option(CJAP_TEST_VST3VALIDATOR_ENABLED "Enable the test using VST3 validator (VST3 only)" ${CJAP_TEST_ENABLED})
option(CJAP_TEST_AAXVALIDATOR_ENABLED "Enable the test using AAX validator (AAX only)" ${CJAP_TEST_ENABLED})
option(CJAP_TEST_ARATESTHOST_ENABLED "Enable the test using ARATestHost (ARA only)" ${CJAP_TEST_ENABLED})
option(CJAP_TEST_FAST_ENABLED "Disable the tests that might be slow" OFF)
option(CJAP_TEST_PLUGINVAL_SKIP_GUI_TESTS "Run plugin tests without the UI" OFF)

# Directory paths to SDKs for plug-in formats. The SDKs will 
# be downloaded into these directories to generate binaries 
# for testing. These paths can be overwritten if the SDKs are 
# already available.  
set(CJAP_TEST_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}" CACHE PATH "The path where the executable are download and the tests performed")
set(CJAP_TEST_VST3_SDK_DIR "${CJAP_TEST_BINARY_DIR}/vst3sdk" CACHE PATH "The path where the VST3 SDK is located")
set(CJAP_TEST_AUDIOUNIT_SDK_DIR "${CJAP_TEST_BINARY_DIR}/ausdk" CACHE PATH "The path where the AudioUnit SDK is located")
set(CJAP_TEST_ARA_SDK_DIR "${CJAP_TEST_BINARY_DIR}/ara" CACHE PATH "The path where the ARA SDK is located")

# ULRs to AAX validators. These URLs muse be defined by the user
# if the SDKs the AAX Validator is enabled and the program is not
# installed on the system.  
set(CJAP_TEST_AAXVALIDATOR_URL_APPLE_arm64 "" CACHE PATH "The URL of the AAX validator for Apple arm64")
set(CJAP_TEST_AAXVALIDATOR_URL_APPLE_x86_64 "" CACHE PATH "The URL of the AAX validator for Apple x86_64")

set(CJAP_TEST_PLUGINVAL_ARGS ${CJAP_TEST_PLUGINVAL_ARGS} "--verbose" "--timeout-ms" "120000" "--validate-in-process")
set(CJAP_TEST_PLUGINVAL_VST3_ARGS ${CJAP_TEST_PLUGINVAL_ARGS} "--strictness-level" "10")
set(CJAP_TEST_PLUGINVAL_AU_ARGS ${CJAP_TEST_PLUGINVAL_ARGS} "--strictness-level" "5")

# Force configurations based on the OS
if(UNIX AND NOT APPLE)
  # VST3, AAX and AUVAL validators are not supported on Linux
  set(CJAP_TEST_VST3VALIDATOR_ENABLED OFF)
  set(CJAP_TEST_AAXVALIDATOR_ENABLED OFF)
  set(CJAP_TEST_AUVAL_ENABLED OFF)
elseif(WIN32)
  # AAX and AUVAL validators are not supported on Windows (but AAX it should be)
  set(CJAP_TEST_AAXVALIDATOR_ENABLED OFF)
  set(CJAP_TEST_AUVAL_ENABLED OFF)
endif()

# - Verifies and downloads the VST3 SDK
#
# The function checks if the VST3 SDK exists. If not, the VST3 SDK
# is downloaded from the Github repository. If the VST3 SDK already
# exist but its content is corrupted, the functions generates a fatal
# error.
function(cjap_test_check_or_download_vst3_sdk)
  if(EXISTS ${CJAP_TEST_VST3_SDK_DIR})
    if(NOT EXISTS ${CJAP_TEST_VST3_SDK_DIR}/cmake/modules/SMTG_VST3_SDK.cmake)
      message(FATAL_ERROR "The VST3 SDK seems corrupted.")
    endif()
  else()
    execute_process(COMMAND git clone --quiet -c advice.detachedHead=false --depth=1 --shallow-submodules --recursive --single-branch --branch v3.7.1_build_50 https://github.com/steinbergmedia/vst3sdk.git "${CJAP_TEST_VST3_SDK_DIR}" RESULT_VARIABLE DL_RESULT OUTPUT_QUIET)
    if(DL_RESULT)
      message(FATAL_ERROR "The VST3 SDK could not be retrieved: ${DL_RESULT}")
    endif()
  endif()
endfunction(cjap_test_check_or_download_vst3_sdk)

# - Verifies and downloads the AudioUnits SDK
#
# The function checks if the AudioUnits SDK exists. If not, the AudioUnits
# SDK is downloaded from developer.apple.com. If the AudioUnits SDK already
# exist but its content is corrupted, the functions generates a fatal
# error.
function(cjap_test_check_or_download_au_sdk)
  if(EXISTS ${CJAP_TEST_AUDIOUNIT_SDK_DIR})
    if(NOT EXISTS ${CJAP_TEST_AUDIOUNIT_SDK_DIR}/CoreAudio/AudioUnits/AUPublic)
      message(FATAL_ERROR "The AudioUnit SDK seems corrupted.")
    endif()
  else()
    set(CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_URL "https://developer.apple.com/library/archive/samplecode/CoreAudioUtilityClasses/CoreAudioUtilityClasses.zip")
    set(CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_ZIP "${CJAP_TEST_BINARY_DIR}/CoreAudioUtilityClasses.zip")

    if(NOT EXISTS ${CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_ZIP})
      file(DOWNLOAD ${CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_URL} ${CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_ZIP} TIMEOUT 30 STATUS DL_RESULT)
      list(GET DL_RESULT 0 DL_RESULT_CODE)
      if(${DL_RESULT_CODE})
        list(GET DL_RESULT 1 DL_RESULT_ERROR)
        message(FATAL_ERROR "The VST3 SDK could not be retrieved: ${DL_RESULT_ERROR}")
      endif()
    endif()

    if(NOT EXISTS ${CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_ZIP})
      mmessage(FATAL_ERROR "The AudioUnit SDK could not be retrieved")
    endif()

    file(ARCHIVE_EXTRACT INPUT ${CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_ZIP} DESTINATION "${CJAP_TEST_AUDIOUNIT_SDK_DIR}/..")
    file(RENAME "${CJAP_TEST_AUDIOUNIT_SDK_DIR}/../CoreAudioUtilityClasses" ${CJAP_TEST_AUDIOUNIT_SDK_DIR})
    file(REMOVE "${CJAP_TEST_CORE_AUDIO_UTILITY_CLASSES_ZIP}")

    if(NOT EXISTS ${CJAP_TEST_AUDIOUNIT_SDK_DIR})
      message(FATAL_ERROR "Failed to extract Core Audio Utility Classes from downloaded '${CORE_AUDIO_UTILITY_CLASSES_ZIP}'.")
    endif()
  endif()
endfunction(cjap_test_check_or_download_au_sdk)

# - Searchs and downloads the pluginval program
#
# The code searchs for pluginval on the system. If the program cannot be
# found, pluginval is downloaded Github repository. If pluginval cannot be 
# used, the code generates a warning.
if(CJAP_TEST_PLUGINVAL_ENABLED)
  find_program(CJAP_TEST_PLUGINVAL_EXE "pluginval")
  if(NOT CJAP_TEST_PLUGINVAL_EXE)
    if(APPLE)
      file(DOWNLOAD "https://github.com/Tracktion/pluginval/releases/latest/download/pluginval_macOS.zip" "${CJAP_TEST_BINARY_DIR}/pluginval.zip" STATUS DL_RESULT)
    elseif(UNIX)
      file(DOWNLOAD "https://github.com/Tracktion/pluginval/releases/latest/download/pluginval_Linux.zip" "${CJAP_TEST_BINARY_DIR}/pluginval.zip" STATUS DL_RESULT)
    elseif(WIN32)
      file(DOWNLOAD "https://github.com/Tracktion/pluginval/releases/latest/download/pluginval_Windows.zip" "${CJAP_TEST_BINARY_DIR}/pluginval.zip" STATUS DL_RESULT)
    endif()
    list(GET DL_RESULT 0 DL_RESULT_CODE)
    if(${DL_RESULT_CODE})
      list(GET DL_RESULT 1 DL_RESULT_ERROR)
      message(FATAL_ERROR "The VST3 SDK could not be retrieved: ${DL_RESULT_ERROR}")
    endif()
    file(ARCHIVE_EXTRACT INPUT "${CJAP_TEST_BINARY_DIR}/pluginval.zip" DESTINATION ${CJAP_TEST_BINARY_DIR})
    find_program(CJAP_TEST_PLUGINVAL_EXE "pluginval" PATHS ${CJAP_TEST_BINARY_DIR})
  endif()

  if(CJAP_TEST_PLUGINVAL_EXE)
    message(STATUS "Plug-ins tests with pluginval enabled")
    if(CJAP_TEST_PLUGINVAL_SKIP_GUI_TESTS)
      set(CJAP_TEST_PLUGINVAL_VST3_ARGS ${CJAP_TEST_PLUGINVAL_VST3_ARGS} "--skip-gui-tests")
      set(CJAP_TEST_PLUGINVAL_AU_ARGS ${CJAP_TEST_PLUGINVAL_AU_ARGS} "--skip-gui-tests")
    endif()
  else()
    message(WARNING "Plug-ins tests: cant find pluginval")
  endif()
endif(CJAP_TEST_PLUGINVAL_ENABLED)

# - Searchs for the auvaltool program
#
# The code searchs for auvaltool on the system. If the program cannot be 
# found, the function code a warning.
if(CJAP_TEST_AUVAL_ENABLED AND APPLE)
  find_program(CJAP_TEST_AUVAL_EXE "auvaltool")
  if(CJAP_TEST_AUVAL_EXE)
    message(STATUS "Plug-ins tests with auval enabled")
  else()
    message(WARNING "Plug-ins tests: cant find auval")
  endif()
endif(CJAP_TEST_AUVAL_ENABLED AND APPLE)

# - Searchs for the ARATestHost program
#
# The code searchs for ARATestHost on the system. If the program cannot be 
# found, ARATestHost is generated from the ARA SDK. If ARATestHost cannot be 
# used, the code generates a warning. The code requires the VST3 and the
# AudioUnits SDKs.
if(CJAP_TEST_ARATESTHOST_ENABLED)
  find_program(CJAP_TEST_ARATESTHOST_EXE "ARATestHost" PATHS "${CJAP_TEST_BINARY_DIR}/AraTestHost/bin/Release/")
  if(NOT CJAP_TEST_ARATESTHOST_EXE)
    cjap_test_check_or_download_vst3_sdk()
    if(APPLE)
      cjap_test_check_or_download_au_sdk()
      execute_process(COMMAND ${CMAKE_COMMAND} . -B "${CJAP_TEST_BINARY_DIR}/AraTestHost" -G ${CMAKE_GENERATOR} "-DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO" "-DARA_VST3_SDK_DIR=${CJAP_TEST_VST3_SDK_DIR}" "-DARA_AUDIO_UNIT_SDK_DIR=${CJAP_TEST_AUDIOUNIT_SDK_DIR}" "-DARA_SETUP_DEBUGGING=OFF" -Wno-deprecated WORKING_DIRECTORY "${CJAP_TEST_ARA_SDK_DIR}/ARA_Examples" RESULT_VARIABLE DL_RESULT OUTPUT_QUIET)
    elseif(UNIX)
      execute_process(COMMAND ${CMAKE_COMMAND} . -B "${CJAP_TEST_BINARY_DIR}/AraTestHost" -G ${CMAKE_GENERATOR} "-DARA_VST3_SDK_DIR=${CJAP_TEST_VST3_SDK_DIR}" "-DARA_SETUP_DEBUGGING=OFF" -Wno-deprecated WORKING_DIRECTORY "${CJAP_TEST_ARA_SDK_DIR}/ARA_Examples" RESULT_VARIABLE DL_RESULT OUTPUT_QUIET)
    elseif(WIN32)
      execute_process(COMMAND ${CMAKE_COMMAND} . -B "${CJAP_TEST_BINARY_DIR}/AraTestHost" -G ${CMAKE_GENERATOR} -A ${CMAKE_GENERATOR_PLATFORM} "-DARA_VST3_SDK_DIR=${CJAP_TEST_VST3_SDK_DIR}" "-DARA_SETUP_DEBUGGING=OFF" -Wno-deprecated WORKING_DIRECTORY "${CJAP_TEST_ARA_SDK_DIR}/ARA_Examples" RESULT_VARIABLE DL_RESULT OUTPUT_QUIET)
    endif()
    if(DL_RESULT)
      message(FATAL_ERROR "The ARATestHost could not be generated: ${DL_RESULT}")
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND} --build "${CJAP_TEST_BINARY_DIR}/AraTestHost" --config Release --target ARATestHost RESULT_VARIABLE DL_RESULT OUTPUT_QUIET)
    if(DL_RESULT)
      message(FATAL_ERROR "The ARATestHost could not be compiled: ${DL_RESULT}")
    endif()

    find_program(CJAP_TEST_ARATESTHOST_EXE "ARATestHost" PATHS "${CJAP_TEST_BINARY_DIR}/AraTestHost/bin/Release/")
  endif()

  if(CJAP_TEST_ARATESTHOST_EXE)
    message(STATUS "Plug-ins tests with ARATestHost enabled")
  else()
    message(WARNING "Plug-ins tests: cant find ARATestHost")
  endif()
endif(CJAP_TEST_ARATESTHOST_ENABLED)

# - Searchs and downloads the VST3 validator program
#
# The code searchs for VST3 validator on the system. If the program cannot be
# found, VST3 validator is downloaded and generated from the Github repository. 
# If VST3 validator on cannot be used, the code generates a warning.
if(CJAP_TEST_VST3VALIDATOR_ENABLED)
  cjap_test_check_or_download_vst3_sdk()
  if(CJAP_TEST_ARATESTHOST_ENABLED)
    find_program(CJAP_TEST_VST3VALIDATOR_EXE "validator" PATHS "${CJAP_TEST_BINARY_DIR}/AraTestHost/bin/Release/" "${CJAP_TEST_BINARY_DIR}/Vst3Validator/bin/Release")
  else()
    find_program(CJAP_TEST_VST3VALIDATOR_EXE "validator" PATHS "${CJAP_TEST_BINARY_DIR}/Vst3Validator/bin/Release")
  endif()
  if(NOT CJAP_TEST_VST3VALIDATOR_EXE)
    if(UNIX)
      execute_process(COMMAND ${CMAKE_COMMAND} -B "${CJAP_TEST_BINARY_DIR}/Vst3Validator" -G ${CMAKE_GENERATOR} -Wno-deprecated WORKING_DIRECTORY ${CJAP_TEST_VST3_SDK_DIR} OUTPUT_QUIET)
    elseif(WIN32)
      execute_process(COMMAND ${CMAKE_COMMAND} -B "${CJAP_TEST_BINARY_DIR}/Vst3Validator" -G ${CMAKE_GENERATOR} -A ${CMAKE_GENERATOR_PLATFORM} -Wno-deprecated  WORKING_DIRECTORY ${CJAP_TEST_VST3_SDK_DIR} OUTPUT_QUIET)
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND} --build "${CJAP_TEST_BINARY_DIR}/Vst3Validator" --config Release --target validator OUTPUT_QUIET)
    find_program(CJAP_TEST_VST3VALIDATOR_EXE "validator" PATHS "${CJAP_TEST_BINARY_DIR}/Vst3Validator/bin/Release")
  endif()

  if(CJAP_TEST_VST3VALIDATOR_EXE)
    message(STATUS "Plug-ins tests with VST3 validator enabled")
  else()
    message(WARNING "Plug-ins tests: cant find VST3 validator")
  endif()

  if(CJAP_TEST_VST3VALIDATOR_EXE AND CJAP_TEST_PLUGINVAL_ENABLED)
    set(CJAP_TEST_PLUGINVAL_VST3_ARGS ${CJAP_TEST_PLUGINVAL_VST3_ARGS} "--vst3validator" ${CJAP_TEST_VST3VALIDATOR_EXE})
  endif()
endif(CJAP_TEST_VST3VALIDATOR_ENABLED)

# AAX validator
# - Searchs and downloads the AAX validator program
#
# The code searchs for AAX validator on the system. If the program cannot be
# found, AAX validator is downloaded from the user-defined URLs. 
# If VST3 validator on cannot be used, the code generates a warning.
if(CJAP_TEST_AAXVALIDATOR_ENABLED)
  find_program(CJAP_TEST_AAX_DTT_EXE "run_test.command")
  if(NOT CJAP_TEST_AAX_DTT_EXE)
    set(CJAP_TEST_AAX_BINARY_DIR "${CJAP_TEST_BINARY_DIR}/aax-developer-tools")
    if(APPLE AND ${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "arm64")
      file(DOWNLOAD ${CJAP_TEST_AAXVALIDATOR_URL_APPLE_arm64} "${CJAP_TEST_AAX_BINARY_DIR}/aax-developer-tools.tar.gz" STATUS DL_RESULT)
    elseif(APPLE AND ${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86_64")
      file(DOWNLOAD ${CJAP_TEST_AAXVALIDATOR_URL_APPLE_x86_64} "${CJAP_TEST_AAX_BINARY_DIR}/aax-developer-tools.tar.gz" STATUS DL_RESULT)
    endif()
    list(GET DL_RESULT 0 DL_RESULT_CODE)
    if(${DL_RESULT_CODE})
      list(GET DL_RESULT 1 DL_RESULT_ERROR)
      message(FATAL_ERROR "The AAX validator could not be retrieved: ${DL_RESULT_ERROR}")
    endif()
    file(ARCHIVE_EXTRACT INPUT "${CJAP_TEST_AAX_BINARY_DIR}/aax-developer-tools.tar.gz" DESTINATION "${CJAP_TEST_AAX_BINARY_DIR}")
    file(GLOB_RECURSE CJAP_TEST_AAX_DTT_EXE_PATHS ${CJAP_TEST_AAX_BINARY_DIR}/*/run_test.command)
    list(GET CJAP_TEST_AAX_DTT_EXE_PATHS 0 CJAP_TEST_AAX_DTT_EXE_PATH)
    cmake_path(GET CJAP_TEST_AAX_DTT_EXE_PATH PARENT_PATH CJAP_TEST_AAX_DTT_EXE_PATH_DIR)
    find_program(CJAP_TEST_AAX_DTT_EXE "run_test.command" PATHS ${CJAP_TEST_AAX_DTT_EXE_PATH_DIR})
  endif()

  if(CJAP_TEST_AAX_DTT_EXE)
    file(MAKE_DIRECTORY ${CJAP_TEST_BINARY_DIR}/aax_tests)
    set(CJAP_TEST_AAXVALIDATOR_EXE "${CJAP_TEST_BINARY_DIR}/aax_tests/runner")
    file(WRITE "${CJAP_TEST_AAXVALIDATOR_EXE}" "#!/bin/sh\n\n")
    function(add_aax_test test_id)
      file(APPEND "${CJAP_TEST_AAXVALIDATOR_EXE}" "${CJAP_TEST_AAX_DTT_EXE} --script '4' -a 'pi_path='$1'' -a 'result_format=json' -a 'out_path=${CJAP_TEST_BINARY_DIR}/aax_tests' -a 'test_id=${test_id}'\n")
    endfunction(add_aax_test)
    add_aax_test("info.productids")
    add_aax_test("info.support.audiosuite")
    add_aax_test("info.support.general")
    add_aax_test("info.support.host_context")
    add_aax_test("info.support.s6_feature")
    add_aax_test("info.support.satin")
    # add_aax_test("test.cycle_counts") # Ignored because this is a DSP plug-in test
    add_aax_test("test.data_model")
    add_aax_test("test.describe_validation")
    # add_aax_test("test.page_table.automation_list") # Ignored because there is no XML page
    # add_aax_test("test.page_table.load") # Ignored because there is no XML page
    if(NOT CJAP_TEST_FAST_ENABLED)
      add_aax_test("test.load_unload")
      # add_aax_test("test.parameter_traversal.linear") # ~3 minutes
      # add_aax_test("test.parameter_traversal.random") # ~30 seconds
      add_aax_test("test.parameter_traversal.random.fast")
      add_aax_test("test.parameters")
    endif()

    file(CHMOD "${CJAP_TEST_AAXVALIDATOR_EXE}" FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
    message(STATUS "Plug-ins tests with AAX validator enabled")
  else()
    message(WARNING "Plug-ins tests: cant find AAX validator")
  endif()
endif(CJAP_TEST_AAXVALIDATOR_ENABLED)

# - Enables the VST3 tests for the target
#
# The function enables the VST3 tests for the target.
# The tests use the pluginval program with the VST3 validator if available.
# If the target is an ARA plug-in, the tests are also performed using
# the ARATestHost program if available.
function(target_enable_cjap_test_vst3 target)
  if(TARGET ${target}_VST3)
    get_target_property(ARTEFACT_FILE_VST3 ${target}_VST3 JUCE_PLUGIN_ARTEFACT_FILE)
    if(CJAP_TEST_PLUGINVAL_EXE)
      add_test(NAME PluginVal_Test_${target}_VST3 COMMAND ${CJAP_TEST_PLUGINVAL_EXE} ${CJAP_TEST_PLUGINVAL_VST3_ARGS} --validate "${ARTEFACT_FILE_VST3}")
    endif()

    get_target_property(CJAP_TEST_VST3_IS_PLUGIN_ARA_EFFECT ${target} JUCE_IS_ARA_EFFECT)
    if(CJAP_TEST_ARATESTHOST_EXE AND ${CJAP_TEST_VST3_IS_PLUGIN_ARA_EFFECT})
      if(NOT APPLE)
        get_target_property(LIBRARY_OUTPUT_NAME ${target} JUCE_PRODUCT_NAME)
        get_target_property(LIBRARY_OUTPUT_SUFFIX ${target}_VST3 SUFFIX)
        get_target_property(LIBRARY_OUTPUT_DIR ${target}_VST3 LIBRARY_OUTPUT_DIRECTORY)
        add_test(NAME AraTestHost_Test_${target}_VST3 COMMAND ${CJAP_TEST_ARATESTHOST_EXE} -vst3 "${LIBRARY_OUTPUT_DIR}/${LIBRARY_OUTPUT_NAME}${LIBRARY_OUTPUT_SUFFIX}")
      else()
        add_test(NAME AraTestHost_Test_${target}_VST3 COMMAND ${CJAP_TEST_ARATESTHOST_EXE} -vst3 "${ARTEFACT_FILE_VST3}")
      endif()
    endif()
  endif()
endfunction(target_enable_cjap_test_vst3)

# - Enables the AudioUnits tests for the target
#
# The function enables the AudioUnits tests for the target.
# The tests use the auval program and the pluginval program if available.
# If the target is an ARA plug-in, the tests are also performed using
# the ARATestHost program if available.
function(target_enable_cjap_test_audiounit target)
  if(CJAP_TEST_AUVAL_EXE AND APPLE AND TARGET ${target}_AU)
    get_target_property(target_plugin_code ${target} JUCE_PLUGIN_CODE)
    get_target_property(target_plugin_manufacturer_code ${target} JUCE_PLUGIN_MANUFACTURER_CODE)
    get_target_property(target_plugin_au_main_type_code ${target} JUCE_AU_MAIN_TYPE_CODE)
    string(SUBSTRING ${target_plugin_au_main_type_code} 1 4 target_plugin_au_main_type_code)

    file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Testing/AUVal_Test_${target}.sh CONTENT "#!/bin/sh\n\nrm -rf \"$ENV{HOME}/Library/Audio/Plug-Ins/Components/$1\"\nrm -rf \"/Library/Audio/Plug-Ins/Components/$1\"\ncp -r \"$2\" \"$ENV{HOME}/Library/Audio/Plug-Ins/Components/\"\n${CJAP_TEST_AUVAL_EXE} -strict -q -v ${target_plugin_au_main_type_code} ${target_plugin_code} ${target_plugin_manufacturer_code}\n" FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
    
    get_target_property(ARTEFACT_FILE_AU ${target}_AU JUCE_PLUGIN_ARTEFACT_FILE)
    add_test(NAME AUVal_Test_${target}_AU COMMAND ${CMAKE_CURRENT_BINARY_DIR}/Testing/AUVal_Test_${target}.sh "$<TARGET_FILE_NAME:${target}_AU>.component" "${ARTEFACT_FILE_AU}")

    if(CJAP_TEST_PLUGINVAL_EXE)
      add_test(NAME PluginVal_Test_${target}_AU COMMAND ${CJAP_TEST_PLUGINVAL_EXE} ${CJAP_TEST_PLUGINVAL_AU_ARGS} --validate "${ARTEFACT_FILE_AU}")
      set_tests_properties(PluginVal_Test_${target}_AU PROPERTIES DEPENDS "AUVal_Test_${target}_AU")
    endif()

    get_target_property(CJAP_TEST_AU_IS_PLUGIN_ARA_EFFECT ${target} JUCE_IS_ARA_EFFECT)
    if(CJAP_TEST_ARATESTHOST_EXE AND ${CJAP_TEST_AU_IS_PLUGIN_ARA_EFFECT})
      add_test(NAME AraTestHost_Test_${target}_AU COMMAND ${CJAP_TEST_ARATESTHOST_EXE} -au ${target_plugin_au_main_type_code} ${target_plugin_code} ${target_plugin_manufacturer_code})
      set_tests_properties(AraTestHost_Test_${target}_AU PROPERTIES DEPENDS "AUVal_Test_${target}_AU")
    endif() 
  endif()
endfunction(target_enable_cjap_test_audiounit)

# - Enables the AAX tests for the target
#
# The function enables the AAX tests for the target.
# The tests use the AAX validaotr program if available.
function(target_enable_cjap_test_aax target)
  if(TARGET ${target}_AAX AND CJAP_TEST_AAXVALIDATOR_EXE)
    get_target_property(ARTEFACT_FILE_AAX ${target}_AAX JUCE_PLUGIN_ARTEFACT_FILE)
    add_test(NAME AAXValidator_Test_${target}_AAX COMMAND ${CJAP_TEST_AAXVALIDATOR_EXE} '${ARTEFACT_FILE_AAX}')
    set_tests_properties(AAXValidator_Test_${target}_AAX PROPERTIES FAIL_REGULAR_EXPRESSION "1 failed")
  endif()
endfunction(target_enable_cjap_test_aax)

# - Enables all the test for the target
#
# The function enables all the tests:
# VST3, AudioUnits, AAX
function(target_enable_cjap_test target)
  target_enable_cjap_test_vst3(${target})
  target_enable_cjap_test_audiounit(${target})
  target_enable_cjap_test_aax(${target})
endfunction(target_enable_cjap_test)

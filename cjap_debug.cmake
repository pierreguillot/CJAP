# - CMake JUCE Audio Plug-in Debugging
#
# This file contains functions for debugging the plug-ins. 
# ToDo: Add support for other generators than Xcode

# Option for enabling the the debugging.
option(CJAP_DEBUG_ENABLED "Enable the debugging using custom host" ON)

# The program to debug the plug-ins
set(CJAP_DEBUG_ENVIRONMENT "" CACHE STRING "Environment varaible for debugging plug-ins")
set(CJAP_DEBUG_EXE_FOR_VST3 "Reaper" CACHE STRING "Executable used for debugging VST3 plug-ins")
set(CJAP_DEBUG_EXE_FOR_AUDIOUNIT "Logic Pro X" CACHE STRING "Executable used for debugging AudioUnit plug-ins")
set(CJAP_DEBUG_EXE_FOR_AAX "Pro Tools Developer" CACHE STRING "Executable used for debugging AAX plug-ins")

# - Searchs for the program to debug
#
# The code searchs for the program to debug and
# generates warnings if a program cannot be found.
if(CJAP_DEBUG_ENABLED AND APPLE)
  function(jap_debug_get_app_bundle APP_PATH_VAR APP_NAME)
    find_program(APD_PROGRAM ${APP_NAME} NO_CACHE)
    if(APD_PROGRAM AND NOT IS_DIRECTORY ${APD_PROGRAM}) 
      cmake_path(GET APD_PROGRAM PARENT_PATH APD_PROGRAM_PARENT)
      cmake_path(SET APD_PROGRAM NORMALIZE "${APD_PROGRAM_PARENT}/../../")
    endif()
    set(${APP_PATH_VAR} ${APD_PROGRAM} PARENT_SCOPE)
  endfunction(jap_debug_get_app_bundle)

  # VST3
  jap_debug_get_app_bundle(CJAP_DEBUG_EXE_VST3 ${CJAP_DEBUG_EXE_FOR_VST3})
  if(CJAP_DEBUG_EXE_VST3)
    message(STATUS "Plug-ins debug VST3: " ${CJAP_DEBUG_EXE_VST3})
    set(CJAP_DEBUG_EXE_DEFAULT ${CJAP_DEBUG_EXE_VST3})
  else()
    message(STATUS "Plug-ins debug VST3: executable not found")
  endif()
  
  # Audio Unit
  jap_debug_get_app_bundle(CJAP_DEBUG_EXE_AUDIOUNIT ${CJAP_DEBUG_EXE_FOR_AUDIOUNIT})
  if(CJAP_DEBUG_EXE_AUDIOUNIT)
    message(STATUS "Plug-ins debug AudioUnit: " ${CJAP_DEBUG_EXE_AUDIOUNIT})
  elseif(CJAP_DEBUG_EXE_DEFAULT)
    set(CJAP_DEBUG_EXE_AUDIOUNIT ${CJAP_DEBUG_EXE_DEFAULT})
    message(STATUS "Plug-ins debug AudioUnit: " ${CJAP_DEBUG_EXE_AUDIOUNIT} "(fallback)")
  else()
    message(STATUS "Plug-ins debug AudioUnit: executable not found")
  endif()
  
  # AAX
  jap_debug_get_app_bundle(CJAP_DEBUG_EXE_AAX ${CJAP_DEBUG_EXE_FOR_AAX})
  if(CJAP_DEBUG_EXE_AAX)
    message(STATUS "Plug-ins debug AAX: " ${CJAP_DEBUG_EXE_AAX})
  elseif(CJAP_DEBUG_EXE_DEFAULT)
    set(CJAP_DEBUG_EXE_AAX ${CJAP_DEBUG_EXE_DEFAULT})
    message(STATUS "Plug-ins debug AAX: " ${CJAP_DEBUG_EXE_AAX} "(fallback)")
  else()
    message(STATUS "Plug-ins debug AAX: executable not found")
  endif()
endif()

# - Defines the copy path if necessary
if(CJAP_DEBUG_EXE_FOR_VST3 STREQUAL "Cubase")
  if(APPLE)
    cmake_path(SET CJAP_DEBUG_COPY_PATH NORMALIZE "$ENV{HOME}/Library/Audio/Plug-Ins")
  elseif(WIN32)
    cmake_path(SET CJAP_DEBUG_COPY_PATH NORMALIZE $ENV{COMMONPROGRAMFILES})
  else()
    cmake_path(SET CJAP_DEBUG_COPY_PATH NORMALIZE $ENV{HOME})
  endif()
  message(STATUS "Plug-ins debug path: ${CJAP_DEBUG_COPY_PATH}")
endif()

# - Copies the ARA plugin for Cubase
function(target_enable_cjap_debug_copy_ara_for_cubase target)
  get_target_property(CJAP_DEBUG_COPY_PLUGIN_AFTER_BUILD ${target} JUCE_COPY_PLUGIN_AFTER_BUILD)
  get_target_property(CJAP_DEBUG_IS_PLUGIN_ARA_EFFECT ${target} JUCE_IS_ARA_EFFECT)
  if(NOT CJAP_DEBUG_COPY_PATH STREQUAL "" AND CJAP_DEBUG_IS_PLUGIN_ARA_EFFECT AND TARGET ${target}_VST3 AND CJAP_DEBUG_COPY_PLUGIN_AFTER_BUILD)
    if(APPLE OR WIN32)
      get_target_property(ARTEFACT_FILE_VST3 ${target}_VST3 JUCE_PLUGIN_ARTEFACT_FILE)
      add_custom_command(TARGET ${target} POST_BUILD COMMAND ${CMAKE_COMMAND} "-Dsrc=${ARTEFACT_FILE_VST3}" "-Ddest=${CJAP_DEBUG_COPY_PATH}/ARA" "-P" "${JUCE_CMAKE_UTILS_DIR}/copyDir.cmake" VERBATIM)
    endif()
  endif()
endfunction(target_enable_cjap_debug_copy_ara_for_cubase)

# - Enables the debugging for the target
#
# The function enables the code-signing for:
# VST3, AudioUnits, AAX
function(target_enable_cjap_debug target)
  if(APPLE)
    if(CJAP_DEBUG_EXE_DEFAULT)
      set_target_properties(${target} PROPERTIES XCODE_SCHEME_EXECUTABLE ${CJAP_DEBUG_EXE_DEFAULT})
      set_target_properties(${target} PROPERTIES XCODE_SCHEME_ENVIRONMENT "${CJAP_DEBUG_ENVIRONMENT}")
      set_target_properties(${target}_All PROPERTIES XCODE_SCHEME_EXECUTABLE ${CJAP_DEBUG_EXE_DEFAULT})
      set_target_properties(${target}_All PROPERTIES XCODE_SCHEME_ENVIRONMENT "${CJAP_DEBUG_ENVIRONMENT}")
    endif()
    
    if(CJAP_DEBUG_EXE_VST3 AND TARGET ${target}_VST3)
      set_target_properties(${target}_VST3 PROPERTIES XCODE_SCHEME_EXECUTABLE ${CJAP_DEBUG_EXE_VST3})
      set_target_properties(${target}_VST3 PROPERTIES XCODE_SCHEME_ENVIRONMENT "${CJAP_DEBUG_ENVIRONMENT}")
    endif()
    
    if(CJAP_DEBUG_EXE_AUDIOUNIT AND TARGET ${target}_AU)
      set_target_properties(${target}_AU PROPERTIES XCODE_SCHEME_EXECUTABLE ${CJAP_DEBUG_EXE_AUDIOUNIT})
      set_target_properties(${target}_AU PROPERTIES XCODE_SCHEME_ENVIRONMENT "${CJAP_DEBUG_ENVIRONMENT}")
    endif()
    
    if(CJAP_DEBUG_EXE_AAX AND TARGET ${target}_AAX)
      set_target_properties(${target}_AAX PROPERTIES XCODE_SCHEME_EXECUTABLE ${CJAP_DEBUG_EXE_AAX})
      set_target_properties(${target}_AAX PROPERTIES XCODE_SCHEME_ENVIRONMENT "${CJAP_DEBUG_ENVIRONMENT}")
    endif()
  endif()
  target_enable_cjap_debug_copy_ara_for_cubase(${target})
endfunction(target_enable_cjap_debug)

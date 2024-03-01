# - CMake JUCE Audio Plug-in
#
# This file includes all the modules for the audio plugin 

include(${CMAKE_CURRENT_LIST_DIR}/cjap_warnings.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cjap_debug.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cjap_test.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cjap_package.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cjap_format.cmake)

# - Enables all the modules for the target
#
# The function enables most of the modules:
# warnings, debug, test, codesign, package
function(target_enable_cjap target)
  target_enable_cjap_warnings(${target})
  target_enable_cjap_debug(${target})
  target_enable_cjap_test(${target})
  target_enable_cjap_codesign(${target})
  target_enable_cjap_package(${target})
endfunction(target_enable_cjap)


# - CMake JUCE Audio Plug-in Format
#
# This file contains functions to check and apply code format

# Options for enabling the warnings.
option(CJAP_FORMAT_ENABLED "Enable the all tests the tests" OFF)

# The files to format
set(CJAP_FORMAT_FILES "${CJAP_FORMAT_FILES}")

# - Creates targets to check and apply code format
if(CJAP_FORMAT_ENABLED)
  find_program(CLANG_FORMAT_EXE "clang-format" HINTS "C:/Program Files/LLVM/bin")
  if(CLANG_FORMAT_EXE)
      if(CJAP_FORMAT_FILES)
        add_custom_target(${CMAKE_PROJECT_NAME}_FormatCheck ${CLANG_FORMAT_EXE} --Werror --dry-run --verbose -style=file ${CJAP_FORMAT_FILES})
        add_custom_target(${CMAKE_PROJECT_NAME}_FormatApply ${CLANG_FORMAT_EXE} -i -style=file ${CJAP_FORMAT_FILES})
      else()
        message(WARNING "${CMAKE_PROJECT_NAME}_FormatCheck and ${CMAKE_PROJECT_NAME}_FormatApply targets cannot be generated because CJAP_FORMAT_FILES is empty")
      endif()
  else()
      message(WARNING "${CMAKE_PROJECT_NAME}_FormatCheck and ${CMAKE_PROJECT_NAME}_FormatApply targets cannot be generated because clang-format is not found")
  endif()
endif()

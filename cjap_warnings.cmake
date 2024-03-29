# - CMake JUCE Audio Plug-in Warnings
#
# This file contains functions that increase the warning level
# of the targets. 
# ToDo: Add support for other generators than Xcode

# Options for enabling the warnings.
option(CJAP_WARNINGS_ENABLED "Enable the all tests the tests" ON)

# - Enables all the warnings for the target
#
# The function enables most of the warnings for Xcode.
# Other generators should be supported in the future.
# This can be used in conjunction with juce::juce_recommended_warning_flags.
function(target_enable_cjap_warnings target)
  if(CJAP_WARNINGS_ENABLED AND CMAKE_GENERATOR STREQUAL Xcode)
    target_compile_options(${target} PRIVATE -Wall -Wextra -pedantic)

    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_PEDANTIC "YES")

    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_CHECK_SWITCH_STATEMENTS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_EMPTY_BODY "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_BOOL_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_CONSTANT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_DIRECT_OBJC_ISA_USAGE  "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_EMPTY_BODY "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_ENUM_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_FLOAT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_INT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_NON_LITERAL_NULL_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_IMPLICIT_SIGN_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_OBJC_ROOT_CLASS  "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_UNREACHABLE_CODE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN__DUPLICATE_METHOD_MATCH "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_FOUR_CHARACTER_CONSTANTS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_SHADOW "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_64_TO_32_BIT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_ABOUT_RETURN_TYPE  "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNDECLARED_SELECTOR "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNINITIALIZED_AUTOS  "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNUSED_FUNCTION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNUSED_VARIABLE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_BOOL_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_CONSTANT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_DIRECT_OBJC_ISA_USAGE  "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_EMPTY_BODY "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_ENUM_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_INT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_OBJC_ROOT_CLASS  "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_UNREACHABLE_CODE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN__DUPLICATE_METHOD_MATCH "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_64_TO_32_BIT_CONVERSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_ABOUT_RETURN_TYPE  "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNDECLARED_SELECTOR "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNINITIALIZED_AUTOS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNKNOWN_PRAGMAS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNUSED_FUNCTION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNUSED_PARAMETER "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_UNUSED_LABEL "YES")

    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_EXIT_TIME_DESTRUCTORS "NO")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_NON_VIRTUAL_DESTRUCTOR "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_RANGE_LOOP_ANALYSIS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_SUSPICIOUS_MOVE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_CXX0X_EXTENSIONS "YES")

    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_INFINITE_RECURSION "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_ABOUT_MISSING_PROTOTYPES "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_ABOUT_MISSING_NEWLINE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_ASSIGN_ENUM "YES")

    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_WARN_SIGN_COMPARE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_STRICT_PROTOTYPES "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CLANG_WARN_COMMA "YES")

    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_TREAT_INCOMPATIBLE_POINTER_TYPE_WARNINGS_AS_ERRORS "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GCC_TREAT_IMPLICIT_FUNCTION_DECLARATIONS_AS_ERRORS "YES")
  endif()
endfunction()

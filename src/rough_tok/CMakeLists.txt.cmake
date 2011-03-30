cmake_minimum_required (VERSION 2.8)
project (RoughLexer)


set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "$ENV{TRTOK_PATH}/code")
set (LIBS)

find_package (LIBICONV)
find_package (ICU)

if (LIBICONV_FOUND)
  set (USE_ICONV ON CACHE BOOL "Use libiconv for character decoding and encoding. Takes precedence over USE_ICU.")
  set (USE_ICU OFF CACHE BOOL "Use ICU for character decoding and encoding.")
elseif (ICU_FOUND)
  set (USE_ICONV OFF CACHE BOOL "Use libiconv for character decoding and encoding. Takes precedence over USE_ICU.")
  set (USE_ICU ON CACHE BOOL "Use ICU for character decoding and encoding.")
else (LIBICONV_FOUND)
  message (FATAL_ERROR "Neither libiconv nor ICU have been found.")
endif (LIBICONV_FOUND)

if (USE_ICONV)
  include_directories (${LIBICONV_INCLUDE_DIRS})
  link_directories (${LIBICONV_LIBRARY_DIRS})
  set (LIBS ${LIBS} ${LIBICONV_LIBRARIES})
  message (STATUS "Using LIBICONV")
elseif (USE_ICU)
  include_directories (${ICU_INCLUDE_DIRS})
  link_directories (${ICU_LIBRARY_DIRS})
  set (LIBS ${LIBS} ${ICU_LIBRARIES})
  message (STATUS "Using ICU")
endif (USE_ICONV)

build_command (BUILD_COMMAND_VAR)
file (WRITE build_command ${BUILD_COMMAND_VAR})

find_program (QUEX quex quex.bat quex-exe.py REQUIRED HINTS ENV QUEX_PATH DOC "Path to Quex's executable.")
if (USE_ICONV)
  set (QUEX_CONVERTER "--iconv")
elseif (USE_ICU)
  set (QUEX_CONVERTER "--icu")
endif (USE_ICONV)

add_custom_command (OUTPUT RoughLexer RoughLexer.cpp RoughLexer-token
			   RoughLexer-configuration RoughLexer-token_ids
		    COMMAND quex --mode-files		RoughLexer.qx
				 --engine	        RoughLexer
				 --buffer-element-size	4
				 --token-prefix		QUEX_ROUGH_
				 ${QUEX_CONVERTER}
				 --token-id-offset	@QUEX_TOKEN_ID_OFFSET@
		    DEPENDS RoughLexer.qx VERBATIM
		    COMMENT "Building RoughLexer with quex")

include_directories (${CMAKE_CURRENT_SOURCE_DIR}
		     ${CMAKE_CURRENT_BINARY_DIR}
		     $ENV{TRTOK_PATH}/code
		     $ENV{QUEX_PATH})

add_definitions (--std=c++0x)

set (SRCS $ENV{TRTOK_PATH}/code/rough_tok_wrapper.cpp RoughLexer.cpp)
add_library (roughtok MODULE ${SRCS})

target_link_libraries (roughtok ${LIBS})

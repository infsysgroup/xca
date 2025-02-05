find_package(Git)

string(REPLACE "." ";" VERSION_LIST ${PROJECT_VERSION})
list(GET VERSION_LIST 0 PROJECT_VERSION_MAJOR)
list(GET VERSION_LIST 1 PROJECT_VERSION_MINOR)
list(GET VERSION_LIST 2 PROJECT_VERSION_PATCH)

if(Git_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
  message(STATUS "Git found: ${GIT_EXECUTABLE}")
  execute_process(COMMAND git rev-parse HEAD
		WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
		OUTPUT_VARIABLE GIT_REV
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
  )
  execute_process(COMMAND git diff-index --quiet HEAD --
		WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
		OUTPUT_QUIET ERROR_QUIET
		RESULT_VARIABLE GIT_LOCAL_CHANGES
		OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  execute_process(COMMAND git rev-list --count RELEASE.${PROJECT_VERSION}..HEAD
		WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
		OUTPUT_VARIABLE GIT_COMMIT_COUNTER
		RESULT_VARIABLE GIT_COMMIT_COUNTER_RESULT
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
  )
  if(NOT GIT_COMMIT_COUNTER_RESULT)
    math(EXPR PROJECT_VERSION_PATCH "${PROJECT_VERSIONV_PATCH} + ${GIT_COMMIT_COUNTER}")
    set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
    message(STATUS "Commit counter: ${GIT_COMMIT_COUNTER} - ${GIT_REV} - ${PROJECT_VERSION}")
  endif()
  set(RELEASE_TAG "RELEASE.${PROJECT_VERSION}"
	 CACHE STRING "Release TAG for the release")
  if (DEFINED ENV{RELEASE_TAG})
    set(RELEASE_TAG "$ENV{RELEASE_TAG}")
  endif()
  set(RELEASE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}")
  add_custom_command(
	OUTPUT "${RELEASE_NAME}.tar.gz"
	WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
	COMMAND git archive --format=tar.gz --prefix=${RELEASE_NAME}/
		${RELEASE_TAG} > ${CMAKE_BINARY_DIR}/${RELEASE_NAME}.tar.gz
	COMMENT "Create ${RELEASE_NAME}.tar.gz from tag ${RELEASE_TAG}"
  )
  add_custom_target(release DEPENDS ${RELEASE_NAME}.tar.gz)

endif()

message(STATUS "VERSION: ${PROJECT_VERSION}")


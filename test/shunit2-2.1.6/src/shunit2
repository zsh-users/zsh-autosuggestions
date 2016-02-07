#! /bin/sh
# $Id: shunit2 335 2011-05-01 20:10:33Z kate.ward@forestent.com $
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# shUnit2 -- Unit testing framework for Unix shell scripts.
# http://code.google.com/p/shunit2/
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shUnit2 is a xUnit based unit test framework for Bourne shell scripts. It is
# based on the popular JUnit unit testing framework for Java.

# return if shunit already loaded
[ -n "${SHUNIT_VERSION:-}" ] && exit 0

SHUNIT_VERSION='2.1.6'

SHUNIT_TRUE=0
SHUNIT_FALSE=1
SHUNIT_ERROR=2

# enable strict mode by default
SHUNIT_STRICT=${SHUNIT_STRICT:-${SHUNIT_TRUE}}

_shunit_warn() { echo "shunit2:WARN $@" >&2; }
_shunit_error() { echo "shunit2:ERROR $@" >&2; }
_shunit_fatal() { echo "shunit2:FATAL $@" >&2; exit ${SHUNIT_ERROR}; }

# specific shell checks
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt |grep "^shwordsplit$" >/dev/null
  if [ $? -ne ${SHUNIT_TRUE} ]; then
    _shunit_fatal 'zsh shwordsplit option is required for proper operation'
  fi
  if [ -z "${SHUNIT_PARENT:-}" ]; then
    _shunit_fatal "zsh does not pass \$0 through properly. please declare \
\"SHUNIT_PARENT=\$0\" before calling shUnit2"
  fi
fi

#
# constants
#

__SHUNIT_ASSERT_MSG_PREFIX='ASSERT:'
__SHUNIT_MODE_SOURCED='sourced'
__SHUNIT_MODE_STANDALONE='standalone'
__SHUNIT_PARENT=${SHUNIT_PARENT:-$0}

# set the constants readonly
shunit_constants_=`set |grep '^__SHUNIT_' |cut -d= -f1`
echo "${shunit_constants_}" |grep '^Binary file' >/dev/null && \
    shunit_constants_=`set |grep -a '^__SHUNIT_' |cut -d= -f1`
for shunit_constant_ in ${shunit_constants_}; do
  shunit_ro_opts_=''
  case ${ZSH_VERSION:-} in
    '') ;;  # this isn't zsh
    [123].*) ;;  # early versions (1.x, 2.x, 3.x)
    *) shunit_ro_opts_='-g' ;;  # all later versions. declare readonly globally
  esac
  readonly ${shunit_ro_opts_} ${shunit_constant_}
done
unset shunit_constant_ shunit_constants_ shunit_ro_opts_

# variables
__shunit_lineno=''  # line number of executed test
__shunit_mode=${__SHUNIT_MODE_SOURCED}  # operating mode
__shunit_reportGenerated=${SHUNIT_FALSE}  # is report generated
__shunit_script=''  # filename of unittest script (standalone mode)
__shunit_skip=${SHUNIT_FALSE}  # is skipping enabled
__shunit_suite=''  # suite of tests to execute

# counts of tests
__shunit_testSuccess=${SHUNIT_TRUE}
__shunit_testsTotal=0
__shunit_testsPassed=0
__shunit_testsFailed=0

# counts of asserts
__shunit_assertsTotal=0
__shunit_assertsPassed=0
__shunit_assertsFailed=0
__shunit_assertsSkipped=0

# macros
_SHUNIT_LINENO_='eval __shunit_lineno=""; if [ "${1:-}" = "--lineno" ]; then [ -n "$2" ] && __shunit_lineno="[$2] "; shift 2; fi'

#-----------------------------------------------------------------------------
# assert functions
#

# Assert that two values are equal to one another.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertEquals()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertEquals() requires two or three arguments; $# given"
    _shunit_error "1: ${1:+$1} 2: ${2:+$2} 3: ${3:+$3}${4:+ 4: $4}"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_expected_=$1
  shunit_actual_=$2

  shunit_return=${SHUNIT_TRUE}
  if [ "${shunit_expected_}" = "${shunit_actual_}" ]; then
    _shunit_assertPass
  else
    failNotEquals "${shunit_message_}" "${shunit_expected_}" "${shunit_actual_}"
    shunit_return=${SHUNIT_FALSE}
  fi

  unset shunit_message_ shunit_expected_ shunit_actual_
  return ${shunit_return}
}
_ASSERT_EQUALS_='eval assertEquals --lineno "${LINENO:-}"'

# Assert that two values are not equal to one another.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNotEquals()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertNotEquals() requires two or three arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_expected_=$1
  shunit_actual_=$2

  shunit_return=${SHUNIT_TRUE}
  if [ "${shunit_expected_}" != "${shunit_actual_}" ]; then
    _shunit_assertPass
  else
    failSame "${shunit_message_}" "$@"
    shunit_return=${SHUNIT_FALSE}
  fi

  unset shunit_message_ shunit_expected_ shunit_actual_
  return ${shunit_return}
}
_ASSERT_NOT_EQUALS_='eval assertNotEquals --lineno "${LINENO:-}"'

# Assert that a value is null (i.e. an empty string)
#
# Args:
#   message: string: failure message [optional]
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNull()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 1 -o $# -gt 2 ]; then
    _shunit_error "assertNull() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  assertTrue "${shunit_message_}" "[ -z '$1' ]"
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
_ASSERT_NULL_='eval assertNull --lineno "${LINENO:-}"'

# Assert that a value is not null (i.e. a non-empty string)
#
# Args:
#   message: string: failure message [optional]
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNotNull()
{
  ${_SHUNIT_LINENO_}
  if [ $# -gt 2 ]; then  # allowing 0 arguments as $1 might actually be null
    _shunit_error "assertNotNull() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_actual_=`_shunit_escapeCharactersInString "${1:-}"`
  test -n "${shunit_actual_}"
  assertTrue "${shunit_message_}" $?
  shunit_return=$?

  unset shunit_actual_ shunit_message_
  return ${shunit_return}
}
_ASSERT_NOT_NULL_='eval assertNotNull --lineno "${LINENO:-}"'

# Assert that two values are the same (i.e. equal to one another).
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertSame()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertSame() requires two or three arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  assertEquals "${shunit_message_}" "$1" "$2"
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
_ASSERT_SAME_='eval assertSame --lineno "${LINENO:-}"'

# Assert that two values are not the same (i.e. not equal to one another).
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNotSame()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertNotSame() requires two or three arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_:-}$1"
    shift
  fi
  assertNotEquals "${shunit_message_}" "$1" "$2"
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
_ASSERT_NOT_SAME_='eval assertNotSame --lineno "${LINENO:-}"'

# Assert that a value or shell test condition is true.
#
# In shell, a value of 0 is true and a non-zero value is false. Any integer
# value passed can thereby be tested.
#
# Shell supports much more complicated tests though, and a means to support
# them was needed. As such, this function tests that conditions are true or
# false through evaluation rather than just looking for a true or false.
#
# The following test will succeed:
#   assertTrue 0
#   assertTrue "[ 34 -gt 23 ]"
# The folloing test will fail with a message:
#   assertTrue 123
#   assertTrue "test failed" "[ -r '/non/existant/file' ]"
#
# Args:
#   message: string: failure message [optional]
#   condition: string: integer value or shell conditional statement
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertTrue()
{
  ${_SHUNIT_LINENO_}
  if [ $# -gt 2 ]; then
    _shunit_error "assertTrue() takes one two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_condition_=$1

  # see if condition is an integer, i.e. a return value
  shunit_match_=`expr "${shunit_condition_}" : '\([0-9]*\)'`
  shunit_return=${SHUNIT_TRUE}
  if [ -z "${shunit_condition_}" ]; then
    # null condition
    shunit_return=${SHUNIT_FALSE}
  elif [ -n "${shunit_match_}" -a "${shunit_condition_}" = "${shunit_match_}" ]
  then
    # possible return value. treating 0 as true, and non-zero as false.
    [ ${shunit_condition_} -ne 0 ] && shunit_return=${SHUNIT_FALSE}
  else
    # (hopefully) a condition
    ( eval ${shunit_condition_} ) >/dev/null 2>&1
    [ $? -ne 0 ] && shunit_return=${SHUNIT_FALSE}
  fi

  # record the test
  if [ ${shunit_return} -eq ${SHUNIT_TRUE} ]; then
    _shunit_assertPass
  else
    _shunit_assertFail "${shunit_message_}"
  fi

  unset shunit_message_ shunit_condition_ shunit_match_
  return ${shunit_return}
}
_ASSERT_TRUE_='eval assertTrue --lineno "${LINENO:-}"'

# Assert that a value or shell test condition is false.
#
# In shell, a value of 0 is true and a non-zero value is false. Any integer
# value passed can thereby be tested.
#
# Shell supports much more complicated tests though, and a means to support
# them was needed. As such, this function tests that conditions are true or
# false through evaluation rather than just looking for a true or false.
#
# The following test will succeed:
#   assertFalse 1
#   assertFalse "[ 'apples' = 'oranges' ]"
# The folloing test will fail with a message:
#   assertFalse 0
#   assertFalse "test failed" "[ 1 -eq 1 -a 2 -eq 2 ]"
#
# Args:
#   message: string: failure message [optional]
#   condition: string: integer value or shell conditional statement
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertFalse()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 1 -o $# -gt 2 ]; then
    _shunit_error "assertFalse() quires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_condition_=$1

  # see if condition is an integer, i.e. a return value
  shunit_match_=`expr "${shunit_condition_}" : '\([0-9]*\)'`
  shunit_return=${SHUNIT_TRUE}
  if [ -z "${shunit_condition_}" ]; then
    # null condition
    shunit_return=${SHUNIT_FALSE}
  elif [ -n "${shunit_match_}" -a "${shunit_condition_}" = "${shunit_match_}" ]
  then
    # possible return value. treating 0 as true, and non-zero as false.
    [ ${shunit_condition_} -eq 0 ] && shunit_return=${SHUNIT_FALSE}
  else
    # (hopefully) a condition
    ( eval ${shunit_condition_} ) >/dev/null 2>&1
    [ $? -eq 0 ] && shunit_return=${SHUNIT_FALSE}
  fi

  # record the test
  if [ ${shunit_return} -eq ${SHUNIT_TRUE} ]; then
    _shunit_assertPass
  else
    _shunit_assertFail "${shunit_message_}"
  fi

  unset shunit_message_ shunit_condition_ shunit_match_
  return ${shunit_return}
}
_ASSERT_FALSE_='eval assertFalse --lineno "${LINENO:-}"'

#-----------------------------------------------------------------------------
# failure functions
#

# Records a test failure.
#
# Args:
#   message: string: failure message [optional]
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
fail()
{
  ${_SHUNIT_LINENO_}
  if [ $# -gt 1 ]; then
    _shunit_error "fail() requires zero or one arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 1 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi

  _shunit_assertFail "${shunit_message_}"

  unset shunit_message_
  return ${SHUNIT_FALSE}
}
_FAIL_='eval fail --lineno "${LINENO:-}"'

# Records a test failure, stating two values were not equal.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failNotEquals()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "failNotEquals() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_expected_=$1
  shunit_actual_=$2

  _shunit_assertFail "${shunit_message_:+${shunit_message_} }expected:<${shunit_expected_}> but was:<${shunit_actual_}>"

  unset shunit_message_ shunit_expected_ shunit_actual_
  return ${SHUNIT_FALSE}
}
_FAIL_NOT_EQUALS_='eval failNotEquals --lineno "${LINENO:-}"'

# Records a test failure, stating two values should have been the same.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failSame()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "failSame() requires two or three arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi

  _shunit_assertFail "${shunit_message_:+${shunit_message_} }expected not same"

  unset shunit_message_
  return ${SHUNIT_FALSE}
}
_FAIL_SAME_='eval failSame --lineno "${LINENO:-}"'

# Records a test failure, stating two values were not equal.
#
# This is functionally equivalent to calling failNotEquals().
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failNotSame()
{
  ${_SHUNIT_LINENO_}
  if [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "failNotEquals() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  _shunit_shouldSkip && return ${SHUNIT_TRUE}

  shunit_message_=${__shunit_lineno}
  if [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  failNotEquals "${shunit_message_}" "$1" "$2"
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
_FAIL_NOT_SAME_='eval failNotSame --lineno "${LINENO:-}"'

#-----------------------------------------------------------------------------
# skipping functions
#

# Force remaining assert and fail functions to be "skipped".
#
# This function forces the remaining assert and fail functions to be "skipped",
# i.e. they will have no effect. Each function skipped will be recorded so that
# the total of asserts and fails will not be altered.
#
# Args:
#   None
startSkipping()
{
  __shunit_skip=${SHUNIT_TRUE}
}

# Resume the normal recording behavior of assert and fail calls.
#
# Args:
#   None
endSkipping()
{
  __shunit_skip=${SHUNIT_FALSE}
}

# Returns the state of assert and fail call skipping.
#
# Args:
#   None
# Returns:
#   boolean: (TRUE/FALSE constant)
isSkipping()
{
  return ${__shunit_skip}
}

#-----------------------------------------------------------------------------
# suite functions
#

# Stub. This function should contains all unit test calls to be made.
#
# DEPRECATED (as of 2.1.0)
#
# This function can be optionally overridden by the user in their test suite.
#
# If this function exists, it will be called when shunit2 is sourced. If it
# does not exist, shunit2 will search the parent script for all functions
# beginning with the word 'test', and they will be added dynamically to the
# test suite.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#suite() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

# Adds a function name to the list of tests schedule for execution.
#
# This function should only be called from within the suite() function.
#
# Args:
#   function: string: name of a function to add to current unit test suite
suite_addTest()
{
  shunit_func_=${1:-}

  __shunit_suite="${__shunit_suite:+${__shunit_suite} }${shunit_func_}"
  __shunit_testsTotal=`expr ${__shunit_testsTotal} + 1`

  unset shunit_func_
}

# Stub. This function will be called once before any tests are run.
#
# Common one-time environment preparation tasks shared by all tests can be
# defined here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#oneTimeSetUp() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

# Stub. This function will be called once after all tests are finished.
#
# Common one-time environment cleanup tasks shared by all tests can be defined
# here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#oneTimeTearDown() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

# Stub. This function will be called before each test is run.
#
# Common environment preparation tasks shared by all tests can be defined here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#setUp() { :; }

# Note: see _shunit_mktempFunc() for actual implementation
# Stub. This function will be called after each test is run.
#
# Common environment cleanup tasks shared by all tests can be defined here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#tearDown() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

#------------------------------------------------------------------------------
# internal shUnit2 functions
#

# Create a temporary directory to store various run-time files in.
#
# This function is a cross-platform temporary directory creation tool. Not all
# OSes have the mktemp function, so one is included here.
#
# Args:
#   None
# Outputs:
#   string: the temporary directory that was created
_shunit_mktempDir()
{
  # try the standard mktemp function
  ( exec mktemp -dqt shunit.XXXXXX 2>/dev/null ) && return

  # the standard mktemp didn't work.  doing our own.
  if [ -r '/dev/urandom' -a -x '/usr/bin/od' ]; then
    _shunit_random_=`/usr/bin/od -vAn -N4 -tx4 </dev/urandom \
        |sed 's/^[^0-9a-f]*//'`
  elif [ -n "${RANDOM:-}" ]; then
    # $RANDOM works
    _shunit_random_=${RANDOM}${RANDOM}${RANDOM}$$
  else
    # $RANDOM doesn't work
    _shunit_date_=`date '+%Y%m%d%H%M%S'`
    _shunit_random_=`expr ${_shunit_date_} / $$`
  fi

  _shunit_tmpDir_="${TMPDIR:-/tmp}/shunit.${_shunit_random_}"
  ( umask 077 && mkdir "${_shunit_tmpDir_}" ) || \
      _shunit_fatal 'could not create temporary directory! exiting'

  echo ${_shunit_tmpDir_}
  unset _shunit_date_ _shunit_random_ _shunit_tmpDir_
}

# This function is here to work around issues in Cygwin.
#
# Args:
#   None
_shunit_mktempFunc()
{
  for _shunit_func_ in oneTimeSetUp oneTimeTearDown setUp tearDown suite noexec
  do
    _shunit_file_="${__shunit_tmpDir}/${_shunit_func_}"
    cat <<EOF >"${_shunit_file_}"
#! /bin/sh
exit ${SHUNIT_TRUE}
EOF
    chmod +x "${_shunit_file_}"
  done

  unset _shunit_file_
}

# Final cleanup function to leave things as we found them.
#
# Besides removing the temporary directory, this function is in charge of the
# final exit code of the unit test. The exit code is based on how the script
# was ended (e.g. normal exit, or via Ctrl-C).
#
# Args:
#   name: string: name of the trap called (specified when trap defined)
_shunit_cleanup()
{
  _shunit_name_=$1

  case ${_shunit_name_} in
    EXIT) _shunit_signal_=0 ;;
    INT) _shunit_signal_=2 ;;
    TERM) _shunit_signal_=15 ;;
    *)
      _shunit_warn "unrecognized trap value (${_shunit_name_})"
      _shunit_signal_=0
      ;;
  esac

  # do our work
  rm -fr "${__shunit_tmpDir}"

  # exit for all non-EXIT signals
  if [ ${_shunit_name_} != 'EXIT' ]; then
    _shunit_warn "trapped and now handling the (${_shunit_name_}) signal"
    # disable EXIT trap
    trap 0
    # add 128 to signal and exit
    exit `expr ${_shunit_signal_} + 128`
  elif [ ${__shunit_reportGenerated} -eq ${SHUNIT_FALSE} ] ; then
    _shunit_assertFail 'Unknown failure encountered running a test'
    _shunit_generateReport
    exit ${SHUNIT_ERROR}
  fi

  unset _shunit_name_ _shunit_signal_
}

# The actual running of the tests happens here.
#
# Args:
#   None
_shunit_execSuite()
{
  for _shunit_test_ in ${__shunit_suite}; do
    __shunit_testSuccess=${SHUNIT_TRUE}

    # disable skipping
    endSkipping

    # execute the per-test setup function
    setUp

    # execute the test
    echo "${_shunit_test_}"
    eval ${_shunit_test_}

    # execute the per-test tear-down function
    tearDown

    # update stats
    if [ ${__shunit_testSuccess} -eq ${SHUNIT_TRUE} ]; then
      __shunit_testsPassed=`expr ${__shunit_testsPassed} + 1`
    else
      __shunit_testsFailed=`expr ${__shunit_testsFailed} + 1`
    fi
  done

  unset _shunit_test_
}

# Generates the user friendly report with appropriate OK/FAILED message.
#
# Args:
#   None
# Output:
#   string: the report of successful and failed tests, as well as totals.
_shunit_generateReport()
{
  _shunit_ok_=${SHUNIT_TRUE}

  # if no exit code was provided one, determine an appropriate one
  [ ${__shunit_testsFailed} -gt 0 \
      -o ${__shunit_testSuccess} -eq ${SHUNIT_FALSE} ] \
          && _shunit_ok_=${SHUNIT_FALSE}

  echo
  if [ ${__shunit_testsTotal} -eq 1 ]; then
    echo "Ran ${__shunit_testsTotal} test."
  else
    echo "Ran ${__shunit_testsTotal} tests."
  fi

  _shunit_failures_=''
  _shunit_skipped_=''
  [ ${__shunit_assertsFailed} -gt 0 ] \
      && _shunit_failures_="failures=${__shunit_assertsFailed}"
  [ ${__shunit_assertsSkipped} -gt 0 ] \
      && _shunit_skipped_="skipped=${__shunit_assertsSkipped}"

  if [ ${_shunit_ok_} -eq ${SHUNIT_TRUE} ]; then
    _shunit_msg_='OK'
    [ -n "${_shunit_skipped_}" ] \
        && _shunit_msg_="${_shunit_msg_} (${_shunit_skipped_})"
  else
    _shunit_msg_="FAILED (${_shunit_failures_}"
    [ -n "${_shunit_skipped_}" ] \
        && _shunit_msg_="${_shunit_msg_},${_shunit_skipped_}"
    _shunit_msg_="${_shunit_msg_})"
  fi

  echo
  echo ${_shunit_msg_}
  __shunit_reportGenerated=${SHUNIT_TRUE}

  unset _shunit_failures_ _shunit_msg_ _shunit_ok_ _shunit_skipped_
}

# Test for whether a function should be skipped.
#
# Args:
#   None
# Returns:
#   boolean: whether the test should be skipped (TRUE/FALSE constant)
_shunit_shouldSkip()
{
  [ ${__shunit_skip} -eq ${SHUNIT_FALSE} ] && return ${SHUNIT_FALSE}
  _shunit_assertSkip
}

# Records a successful test.
#
# Args:
#   None
_shunit_assertPass()
{
  __shunit_assertsPassed=`expr ${__shunit_assertsPassed} + 1`
  __shunit_assertsTotal=`expr ${__shunit_assertsTotal} + 1`
}

# Records a test failure.
#
# Args:
#   message: string: failure message to provide user
_shunit_assertFail()
{
  _shunit_msg_=$1

  __shunit_testSuccess=${SHUNIT_FALSE}
  __shunit_assertsFailed=`expr ${__shunit_assertsFailed} + 1`
  __shunit_assertsTotal=`expr ${__shunit_assertsTotal} + 1`
  echo "${__SHUNIT_ASSERT_MSG_PREFIX}${_shunit_msg_}"

  unset _shunit_msg_
}

# Records a skipped test.
#
# Args:
#   None
_shunit_assertSkip()
{
  __shunit_assertsSkipped=`expr ${__shunit_assertsSkipped} + 1`
  __shunit_assertsTotal=`expr ${__shunit_assertsTotal} + 1`
}

# Prepare a script filename for sourcing.
#
# Args:
#   script: string: path to a script to source
# Returns:
#   string: filename prefixed with ./ (if necessary)
_shunit_prepForSourcing()
{
  _shunit_script_=$1
  case "${_shunit_script_}" in
    /*|./*) echo "${_shunit_script_}" ;;
    *) echo "./${_shunit_script_}" ;;
  esac
  unset _shunit_script_
}

# Escape a character in a string.
#
# Args:
#   c: string: unescaped character
#   s: string: to escape character in
# Returns:
#   string: with escaped character(s)
_shunit_escapeCharInStr()
{
  [ -n "$2" ] || return  # no point in doing work on an empty string

  # Note: using shorter variable names to prevent conflicts with
  # _shunit_escapeCharactersInString().
  _shunit_c_=$1
  _shunit_s_=$2


  # escape the character
  echo ''${_shunit_s_}'' |sed 's/\'${_shunit_c_}'/\\\'${_shunit_c_}'/g'

  unset _shunit_c_ _shunit_s_
}

# Escape a character in a string.
#
# Args:
#   str: string: to escape characters in
# Returns:
#   string: with escaped character(s)
_shunit_escapeCharactersInString()
{
  [ -n "$1" ] || return  # no point in doing work on an empty string

  _shunit_str_=$1

  # Note: using longer variable names to prevent conflicts with
  # _shunit_escapeCharInStr().
  for _shunit_char_ in '"' '$' "'" '`'; do
    _shunit_str_=`_shunit_escapeCharInStr "${_shunit_char_}" "${_shunit_str_}"`
  done

  echo "${_shunit_str_}"
  unset _shunit_char_ _shunit_str_
}

# Extract list of functions to run tests against.
#
# Args:
#   script: string: name of script to extract functions from
# Returns:
#   string: of function names
_shunit_extractTestFunctions()
{
  _shunit_script_=$1

  # extract the lines with test function names, strip of anything besides the
  # function name, and output everything on a single line.
  _shunit_regex_='^[ 	]*(function )*test[A-Za-z0-9_]* *\(\)'
  egrep "${_shunit_regex_}" "${_shunit_script_}" \
  |sed 's/^[^A-Za-z0-9_]*//;s/^function //;s/\([A-Za-z0-9_]*\).*/\1/g' \
  |xargs

  unset _shunit_regex_ _shunit_script_
}

#------------------------------------------------------------------------------
# main
#

# determine the operating mode
if [ $# -eq 0 ]; then
  __shunit_script=${__SHUNIT_PARENT}
  __shunit_mode=${__SHUNIT_MODE_SOURCED}
else
  __shunit_script=$1
  [ -r "${__shunit_script}" ] || \
      _shunit_fatal "unable to read from ${__shunit_script}"
  __shunit_mode=${__SHUNIT_MODE_STANDALONE}
fi

# create a temporary storage location
__shunit_tmpDir=`_shunit_mktempDir`

# provide a public temporary directory for unit test scripts
# TODO(kward): document this
SHUNIT_TMPDIR="${__shunit_tmpDir}/tmp"
mkdir "${SHUNIT_TMPDIR}"

# setup traps to clean up after ourselves
trap '_shunit_cleanup EXIT' 0
trap '_shunit_cleanup INT' 2
trap '_shunit_cleanup TERM' 15

# create phantom functions to work around issues with Cygwin
_shunit_mktempFunc
PATH="${__shunit_tmpDir}:${PATH}"

# make sure phantom functions are executable. this will bite if /tmp (or the
# current $TMPDIR) points to a path on a partition that was mounted with the
# 'noexec' option. the noexec command was created with _shunit_mktempFunc().
noexec 2>/dev/null || _shunit_fatal \
    'please declare TMPDIR with path on partition with exec permission'

# we must manually source the tests in standalone mode
if [ "${__shunit_mode}" = "${__SHUNIT_MODE_STANDALONE}" ]; then
  . "`_shunit_prepForSourcing \"${__shunit_script}\"`"
fi

# execute the oneTimeSetUp function (if it exists)
oneTimeSetUp

# execute the suite function defined in the parent test script
# deprecated as of 2.1.0
suite

# if no suite function was defined, dynamically build a list of functions
if [ -z "${__shunit_suite}" ]; then
  shunit_funcs_=`_shunit_extractTestFunctions "${__shunit_script}"`
  for shunit_func_ in ${shunit_funcs_}; do
    suite_addTest ${shunit_func_}
  done
fi
unset shunit_func_ shunit_funcs_

# execute the tests
_shunit_execSuite

# execute the oneTimeTearDown function (if it exists)
oneTimeTearDown

# generate the report
_shunit_generateReport

# that's it folks
[ ${__shunit_testsFailed} -eq 0 ]
exit $?

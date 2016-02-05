#! /bin/sh
# $Id: shunit2_test_macros.sh 299 2010-05-03 12:44:20Z kate.ward@forestent.com $
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# shUnit2 unit test for macros.

# load test helpers
. ./shunit2_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testAssertEquals()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_EQUALS_} 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_EQUALS_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_ASSERT_EQUALS_} '"some msg"' 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_EQUALS_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testAssertNotEquals()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_NOT_EQUALS_} 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NOT_EQUALS_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_ASSERT_NOT_EQUALS_} '"some msg"' 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NOT_EQUALS_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testSame()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_SAME_} 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_SAME_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_ASSERT_SAME_} '"some msg"' 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_SAME_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testNotSame()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_NOT_SAME_} 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NOT_SAME_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_ASSERT_NOT_SAME_} '"some msg"' 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NOT_SAME_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testNull()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_NULL_} 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NULL_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_ASSERT_NULL_} '"some msg"' 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NULL_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testNotNull()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_NOT_NULL_} '' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NOT_NULL_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_ASSERT_NOT_NULL_} '"some msg"' '""' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_NOT_NULL_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stdoutF}" "${stderrF}" >&2
}

testAssertTrue()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_TRUE_} ${SHUNIT_FALSE} >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_TRUE_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2


  ( ${_ASSERT_TRUE_} '"some msg"' ${SHUNIT_FALSE} >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_TRUE_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testAssertFalse()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_ASSERT_FALSE_} ${SHUNIT_TRUE} >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_FALSE_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_ASSERT_FALSE_} '"some msg"' ${SHUNIT_TRUE} >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_ASSERT_FALSE_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testFail()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_FAIL_} >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_FAIL_} '"some msg"' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testFailNotEquals()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_FAIL_NOT_EQUALS_} 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_NOT_EQUALS_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_FAIL_NOT_EQUALS_} '"some msg"' 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_NOT_EQUALS_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testFailSame()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_FAIL_SAME_} 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_SAME_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_FAIL_SAME_} '"some msg"' 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_SAME_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testFailNotSame()
{
  # start skipping if LINENO not available
  [ -z "${LINENO:-}" ] && startSkipping

  ( ${_FAIL_NOT_SAME_} 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_NOT_SAME_ failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2

  ( ${_FAIL_NOT_SAME_} '"some msg"' 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  grep '^ASSERT:\[[0-9]*\] *' "${stdoutF}" >/dev/null
  rtrn=$?
  assertTrue '_FAIL_NOT_SAME_ w/ msg failure' ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  tmpDir="${__shunit_tmpDir}/output"
  mkdir "${tmpDir}"
  stdoutF="${tmpDir}/stdout"
  stderrF="${tmpDir}/stderr"
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}

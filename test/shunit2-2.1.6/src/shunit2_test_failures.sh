#! /bin/sh
# $Id: shunit2_test_failures.sh 286 2008-11-24 21:42:34Z kate.ward@forestent.com $
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shUnit2 unit test for failure functions

# load common unit-test functions
. ./shunit2_test_helpers

#-----------------------------------------------------------------------------
# suite tests
#

testFail()
{
  ( fail >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'fail' $? "${stdoutF}" "${stderrF}"

  ( fail "${MSG}" >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'fail with msg' $? "${stdoutF}" "${stderrF}"

  ( fail arg1 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

testFailNotEquals()
{
  ( failNotEquals 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'same' $? "${stdoutF}" "${stderrF}"

  ( failNotEquals "${MSG}" 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'same with msg' $? "${stdoutF}" "${stderrF}"

  ( failNotEquals 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'not same' $? "${stdoutF}" "${stderrF}"

  ( failNotEquals '' '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'null values' $? "${stdoutF}" "${stderrF}"

  ( failNotEquals >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too few arguments' $? "${stdoutF}" "${stderrF}"

  ( failNotEquals arg1 arg2 arg3 arg4 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

testFailSame()
{
  ( failSame 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'same' $? "${stdoutF}" "${stderrF}"

  ( failSame "${MSG}" 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'same with msg' $? "${stdoutF}" "${stderrF}"

  ( failSame 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'not same' $? "${stdoutF}" "${stderrF}"

  ( failSame '' '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'null values' $? "${stdoutF}" "${stderrF}"

  ( failSame >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too few arguments' $? "${stdoutF}" "${stderrF}"

  ( failSame arg1 arg2 arg3 arg4 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

#-----------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  tmpDir="${__shunit_tmpDir}/output"
  mkdir "${tmpDir}"
  stdoutF="${tmpDir}/stdout"
  stderrF="${tmpDir}/stderr"

  MSG='This is a test message'
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}

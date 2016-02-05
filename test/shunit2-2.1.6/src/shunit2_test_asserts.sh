#! /bin/sh
# $Id: shunit2_test_asserts.sh 312 2011-03-14 22:41:29Z kate.ward@forestent.com $
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shUnit2 unit test for assert functions

# load test helpers
. ./shunit2_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

commonEqualsSame()
{
  fn=$1

  ( ${fn} 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'equal' $? "${stdoutF}" "${stderrF}"

  ( ${fn} "${MSG}" 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'equal; with msg' $? "${stdoutF}" "${stderrF}"

  ( ${fn} 'abc def' 'abc def' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'equal with spaces' $? "${stdoutF}" "${stderrF}"

  ( ${fn} 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'not equal' $? "${stdoutF}" "${stderrF}"

  ( ${fn} '' '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'null values' $? "${stdoutF}" "${stderrF}"

  ( ${fn} arg1 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too few arguments' $? "${stdoutF}" "${stderrF}"

  ( ${fn} arg1 arg2 arg3 arg4 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

commonNotEqualsSame()
{
  fn=$1

  ( ${fn} 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not same' $? "${stdoutF}" "${stderrF}"

  ( ${fn} "${MSG}" 'x' 'y' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not same, with msg' $? "${stdoutF}" "${stderrF}"

  ( ${fn} 'x' 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'same' $? "${stdoutF}" "${stderrF}"

  ( ${fn} '' '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'null values' $? "${stdoutF}" "${stderrF}"

  ( ${fn} arg1 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too few arguments' $? "${stdoutF}" "${stderrF}"

  ( ${fn} arg1 arg2 arg3 arg4 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

testAssertEquals()
{
  commonEqualsSame 'assertEquals'
}

testAssertNotEquals()
{
  commonNotEqualsSame 'assertNotEquals'
}

testAssertSame()
{
  commonEqualsSame 'assertSame'
}

testAssertNotSame()
{
  commonNotEqualsSame 'assertNotSame'
}

testAssertNull()
{
  ( assertNull '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'null' $? "${stdoutF}" "${stderrF}"

  ( assertNull "${MSG}" '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'null, with msg' $? "${stdoutF}" "${stderrF}"

  ( assertNull 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'not null' $? "${stdoutF}" "${stderrF}"

  ( assertNull >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too few arguments' $? "${stdoutF}" "${stderrF}"

  ( assertNull arg1 arg2 arg3 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

testAssertNotNull()
{
  ( assertNotNull 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not null' $? "${stdoutF}" "${stderrF}"

  ( assertNotNull "${MSG}" 'x' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not null, with msg' $? "${stdoutF}" "${stderrF}"

  ( assertNotNull 'x"b' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not null, with double-quote' $? \
      "${stdoutF}" "${stderrF}"

  ( assertNotNull "x'b" >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not null, with single-quote' $? \
      "${stdoutF}" "${stderrF}"

  ( assertNotNull 'x$b' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not null, with dollar' $? \
      "${stdoutF}" "${stderrF}"

  ( assertNotNull 'x`b' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'not null, with backtick' $? \
      "${stdoutF}" "${stderrF}"

  ( assertNotNull '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'null' $? "${stdoutF}" "${stderrF}"

  # there is no test for too few arguments as $1 might actually be null

  ( assertNotNull arg1 arg2 arg3 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

testAssertTrue()
{
  ( assertTrue 0 >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'true' $? "${stdoutF}" "${stderrF}"

  ( assertTrue "${MSG}" 0 >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'true, with msg' $? "${stdoutF}" "${stderrF}"

  ( assertTrue '[ 0 -eq 0 ]' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'true condition' $? "${stdoutF}" "${stderrF}"

  ( assertTrue 1 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'false' $? "${stdoutF}" "${stderrF}"

  ( assertTrue '[ 0 -eq 1 ]' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'false condition' $? "${stdoutF}" "${stderrF}"

  ( assertTrue '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'null' $? "${stdoutF}" "${stderrF}"

  ( assertTrue >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too few arguments' $? "${stdoutF}" "${stderrF}"

  ( assertTrue arg1 arg2 arg3 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
}

testAssertFalse()
{
  ( assertFalse 1 >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'false' $? "${stdoutF}" "${stderrF}"

  ( assertFalse "${MSG}" 1 >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'false, with msg' $? "${stdoutF}" "${stderrF}"

  ( assertFalse '[ 0 -eq 1 ]' >"${stdoutF}" 2>"${stderrF}" )
  th_assertTrueWithNoOutput 'false condition' $? "${stdoutF}" "${stderrF}"

  ( assertFalse 0 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'true' $? "${stdoutF}" "${stderrF}"

  ( assertFalse '[ 0 -eq 0 ]' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'true condition' $? "${stdoutF}" "${stderrF}"

  ( assertFalse '' >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithOutput 'true condition' $? "${stdoutF}" "${stderrF}"

  ( assertFalse >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too few arguments' $? "${stdoutF}" "${stderrF}"

  ( assertFalse arg1 arg2 arg3 >"${stdoutF}" 2>"${stderrF}" )
  th_assertFalseWithError 'too many arguments' $? "${stdoutF}" "${stderrF}"
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

  MSG='This is a test message'
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}

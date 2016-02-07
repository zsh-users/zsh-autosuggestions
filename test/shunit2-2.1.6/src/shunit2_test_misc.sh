#! /bin/sh
# $Id: shunit2_test_misc.sh 322 2011-04-24 00:09:45Z kate.ward@forestent.com $
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shUnit2 unit tests of miscellaneous things

# load test helpers
. ./shunit2_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

# Note: the test script is prefixed with '#' chars so that shUnit2 does not
# incorrectly interpret the embedded functions as real functions.
testUnboundVariable()
{
  sed 's/^#//' >"${unittestF}" <<EOF
## treat unset variables as an error when performing parameter expansion
#set -u
#
#boom() { x=\$1; }  # this function goes boom if no parameters are passed!
#test_boom()
#{
#   assertEquals 1 1
#   boom  # No parameter given
#   assertEquals 0 \$?
#}
#. ${TH_SHUNIT}
EOF
  ( exec ${SHUNIT_SHELL:-sh} "${unittestF}" >"${stdoutF}" 2>"${stderrF}" )
  assertFalse 'expected a non-zero exit value' $?
  grep '^ASSERT:Unknown failure' "${stdoutF}" >/dev/null
  assertTrue 'assert message was not generated' $?
  grep '^Ran [0-9]* test' "${stdoutF}" >/dev/null
  assertTrue 'test count message was not generated' $?
  grep '^FAILED' "${stdoutF}" >/dev/null
  assertTrue 'failure message was not generated' $?
}

testIssue7()
{
  ( assertEquals 'Some message.' 1 2 >"${stdoutF}" 2>"${stderrF}" )
  diff "${stdoutF}" - >/dev/null <<EOF
ASSERT:Some message. expected:<1> but was:<2>
EOF
  rtrn=$?
  assertEquals ${SHUNIT_TRUE} ${rtrn}
  [ ${rtrn} -ne ${SHUNIT_TRUE} ] && cat "${stderrF}" >&2
}

testPrepForSourcing()
{
  assertEquals '/abc' `_shunit_prepForSourcing '/abc'`
  assertEquals './abc' `_shunit_prepForSourcing './abc'`
  assertEquals './abc' `_shunit_prepForSourcing 'abc'`
}

testEscapeCharInStr()
{
  actual=`_shunit_escapeCharInStr '\' ''`
  assertEquals '' "${actual}"
  assertEquals 'abc\\' `_shunit_escapeCharInStr '\' 'abc\'`
  assertEquals 'abc\\def' `_shunit_escapeCharInStr '\' 'abc\def'`
  assertEquals '\\def' `_shunit_escapeCharInStr '\' '\def'`

  actual=`_shunit_escapeCharInStr '"' ''`
  assertEquals '' "${actual}"
  assertEquals 'abc\"' `_shunit_escapeCharInStr '"' 'abc"'`
  assertEquals 'abc\"def' `_shunit_escapeCharInStr '"' 'abc"def'`
  assertEquals '\"def' `_shunit_escapeCharInStr '"' '"def'`

  actual=`_shunit_escapeCharInStr '$' ''`
  assertEquals '' "${actual}"
  assertEquals 'abc\$' `_shunit_escapeCharInStr '$' 'abc$'`
  assertEquals 'abc\$def' `_shunit_escapeCharInStr '$' 'abc$def'`
  assertEquals '\$def' `_shunit_escapeCharInStr '$' '$def'`

#  actual=`_shunit_escapeCharInStr "'" ''`
#  assertEquals '' "${actual}"
#  assertEquals "abc\\'" `_shunit_escapeCharInStr "'" "abc'"`
#  assertEquals "abc\\'def" `_shunit_escapeCharInStr "'" "abc'def"`
#  assertEquals "\\'def" `_shunit_escapeCharInStr "'" "'def"`

#  # must put the backtick in a variable so the shell doesn't misinterpret it
#  # while inside a backticked sequence (e.g. `echo '`'` would fail).
#  backtick='`'
#  actual=`_shunit_escapeCharInStr ${backtick} ''`
#  assertEquals '' "${actual}"
#  assertEquals '\`abc' \
#      `_shunit_escapeCharInStr "${backtick}" ${backtick}'abc'`
#  assertEquals 'abc\`' \
#      `_shunit_escapeCharInStr "${backtick}" 'abc'${backtick}`
#  assertEquals 'abc\`def' \
#      `_shunit_escapeCharInStr "${backtick}" 'abc'${backtick}'def'`
}

testEscapeCharInStr_specialChars()
{
  # make sure our forward slash doesn't upset sed
  assertEquals '/' `_shunit_escapeCharInStr '\' '/'`

  # some shells escape these differently
  #assertEquals '\\a' `_shunit_escapeCharInStr '\' '\a'`
  #assertEquals '\\b' `_shunit_escapeCharInStr '\' '\b'`
}

# Test the various ways of declaring functions.
#
# Prefixing (then stripping) with comment symbol so these functions aren't
# treated as real functions by shUnit2.
testExtractTestFunctions()
{
  f="${tmpD}/extract_test_functions"
  sed 's/^#//' <<EOF >"${f}"
#testABC() { echo 'ABC'; }
#test_def() {
#  echo 'def'
#}
#testG3 ()
#{
#  echo 'G3'
#}
#function test4() { echo '4'; }
#	test5() { echo '5'; }
#some_test_function() { echo 'some func'; }
#func_with_test_vars() {
#  testVariable=1234
#}
EOF

  actual=`_shunit_extractTestFunctions "${f}"`
  assertEquals 'testABC test_def testG3 test4 test5' "${actual}"
}

#------------------------------------------------------------------------------
# suite functions
#

setUp()
{
  for f in ${expectedF} ${stdoutF} ${stderrF}; do
    cp /dev/null ${f}
  done
  rm -fr "${tmpD}"
  mkdir "${tmpD}"
}

oneTimeSetUp()
{
  tmpD="${SHUNIT_TMPDIR}/tmp"
  expectedF="${SHUNIT_TMPDIR}/expected"
  stdoutF="${SHUNIT_TMPDIR}/stdout"
  stderrF="${SHUNIT_TMPDIR}/stderr"
  unittestF="${SHUNIT_TMPDIR}/unittest"
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}

#! /bin/sh
# file: examples/lineno_test.sh

testLineNo()
{
  # this assert will have line numbers included (e.g. "ASSERT:[123] ...") if
  # they are supported.
  echo "_ASSERT_EQUALS_ macro value: ${_ASSERT_EQUALS_}"
  ${_ASSERT_EQUALS_} 'not equal' 1 2

  # this assert will not have line numbers included (e.g. "ASSERT: ...")
  assertEquals 'not equal' 1 2
}

# load shunit2
. ../src/shunit2

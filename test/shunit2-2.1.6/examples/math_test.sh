#! /bin/sh
# available as examples/math_test.sh

testAdding()
{
  result=`add_generic 1 2`
  assertEquals \
      "the result of '${result}' was wrong" \
      3 "${result}"

  # disable non-generic tests
  [ -z "${BASH_VERSION:-}" ] && startSkipping

  result=`add_bash 1 2`
  assertEquals \
      "the result of '${result}' was wrong" \
      3 "${result}"
}

oneTimeSetUp()
{
  # load include to test
  . ./math.inc
}

# load and run shUnit2
. ../src/shunit2

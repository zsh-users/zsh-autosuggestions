#! /bin/sh
# $Id: shunit2_test_standalone.sh 303 2010-05-03 13:11:27Z kate.ward@forestent.com $
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2010 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# shUnit2 unit test for standalone operation.
#
# This unit test is purely to test that calling shunit2 directly, while passing
# the name of a unit test script, works. When run, this script determines if it
# is running as a standalone program, and calls main() if it is.

ARGV0=`basename "$0"`

# load test helpers
. ./shunit2_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testStandalone()
{
  assertTrue ${SHUNIT_TRUE}
}

#------------------------------------------------------------------------------
# main
#

main()
{
  ${TH_SHUNIT} "${ARGV0}"
}

# are we running as a standalone?
if [ "${ARGV0}" = 'shunit2_test_standalone.sh' ]; then
  if [ $# -gt 0 ]; then main "$@"; else main; fi
fi

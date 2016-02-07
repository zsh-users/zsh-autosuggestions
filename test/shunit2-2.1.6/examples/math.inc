# available as examples/math.inc

add_generic()
{
  num_a=$1
  num_b=$2

  expr $1 + $2
}

add_bash()
{
  num_a=$1
  num_b=$2

  echo $(($1 + $2))
}

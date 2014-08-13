#!/bin/awk -f


BEGIN {
  FS=",";
}
{

  printf("%s\n", $0);
}
END {
}


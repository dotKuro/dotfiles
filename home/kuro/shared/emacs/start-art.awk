BEGIN {
  print ";;; -*- lexical-binding: t; -*-"
  printf "(defconst kuro/start-art\n  '("
}

/^#/ { next }

{
  split($1, position, /[,:]/)
  if (position[1] == 0) printf "%s(", position[2] == 0 ? "" : ")\n    "
  printf "%s ", substr($3, 8, 2) == "00" ? "nil" : "\"" substr($3, 1, 7) "\""
}

END { print ")))" }

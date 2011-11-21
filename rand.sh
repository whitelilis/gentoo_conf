awk 'BEGIN{srand()}{b[rand()NR]=$0}END{for(x in b)print b[x]}' $1

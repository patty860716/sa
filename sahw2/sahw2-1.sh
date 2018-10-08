#!/bin/sh
ls -lR | sort -n -r -k5 |awk 'BEGIN {count = 0 ;count1 = 0;total = 0}NR<6{print NR". "$9" "$5}/^\./{count++}/^-/{count1++}'$5'{total+=$5}END{print "Dir num:"count "\nfile num: "count1"\ntotal:"total}'


#!/bin/sh

for i in tests/*T.h
do
	testlines=$(wc -l "$i" | awk '{print $1}')
	class=${i%T.h}
	class=${class#tests/}
	codelines=$(cat */"$class".{cpp,h} | wc -l | awk '{print $1}')
	echo $class $codelines $testlines \
		$(dc -e "3 k $testlines $codelines / p")
done

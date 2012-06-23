#!/bin/sh

find . -type f -name "* *"|sed -e 's/^..//' -e "s/^/'/" -e "s/$/'/" > MANIFEST 
find . -type f ! -name "* *"|sed 's/^..//' >> MANIFEST 
# grep ^MANIFEST MANIFEST || echo MANIFEST >> MANIFEST #should not need this line
cpansign -s

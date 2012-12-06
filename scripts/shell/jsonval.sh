#!/bin/bash

#fetch tweeter avatars

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
}
user='BarackObama'
if [ $1 ]
then
    user=$1
fi

json=`curl -s -X GET https://twitter.com/users/show/${user}.json`
prop='profile_image_url'
picurl=`jsonval`

`curl -s -X GET $picurl -o ${user}.png`

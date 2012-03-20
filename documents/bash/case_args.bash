#!/bin/bash                                                               
# variable third argument

help() {
     echo "This needs at least two argument"; exit; 
}

[ "$2" ] || help

# by looping though the #$args we can extract all of the arguments
if [ "$3" ]
then
    echo "You have a third argument!";
    case "$3" in                                                       
    -h|--help) help;;                               
    -f|--force) echo "force";;                               
    -d|d|debug) echo "debug";;                               
    -v|-V) 
        echo "verbose output enabled"
        echo "(we can use as many lines as we need, or keep it tidy by using a function)"
    ;;                               
    *      ) echo "unknown argument";;              
    esac
fi
exit 0                                                                    

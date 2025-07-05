#!/bin/bash
setxkbmap -query | awk '/layout/ { 
    if ($2 == "us") print "en"; 
    else print $2 
}' 


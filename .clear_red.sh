#!/bin/bash

for run in {1..200}; do
    sleep .001 
    for win in $(wmctrl -l | awk -F' ' '{print $1}'); do
        wmctrl -i -r $win -b remove,demands_attention
    done
done

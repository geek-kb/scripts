#!/bin/bash
path="$1"
df -H | grep $path
size=$(df -H | grep $path | awk '{print $2}')
used=$(df -H | grep $path | awk '{print $3}')
avail=$(df -H | grep $path | awk '{print $4}')


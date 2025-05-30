#!/bin/bash

read -p "Please enter a path to the file: " TARGETS

for i in $TARGETS
do
    nikto -host $i
done
#!/bin/bash

msg=$(mix sobelow --config --verbose)
echo "$msg"

error=$(echo "$msg" | grep -o 'Confidence' | wc -l)

echo

echo $error
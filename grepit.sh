#!/bin/bash

msg=$(mix sobelow)
echo "$msg"

error=$(echo "$msg" | grep -o 'Confidence')

echo

echo $error
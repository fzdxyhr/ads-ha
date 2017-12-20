#!/bin/bash

myFile=$1
if [ -f "$myFile" ];then
    rm -f $myFile
fi
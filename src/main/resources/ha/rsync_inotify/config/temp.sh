#!/bin/bash

cat path.txt | awk 'NR>1' | while read line
do
    echo $line
done

#!/bin/bash
cat path.txt | awk 'NR>1' | while read line
do
    OLD_IFS="$IFS" 
	IFS=":" 
	arr=($line) 
	IFS="$OLD_IFS" 
	echo ${arr[0]}
	echo ${arr[1]}
	echo ${arr[2]}
done

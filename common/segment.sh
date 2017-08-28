#!/bin/bash
#分割字符串
str=$1
step=$2

if [ -z "$step" ]; then
    step=120
fi

if [ ! -z "$str" ]; then
    len=${#str}
    num=$[$len/$step]
    if [ $[$len%$step] -ne 0 ]; then
        num=$[$num+1]
    fi
    
    for ((i=0;i<$num;i++))
    do
       #echo ${str:$[$step*$i]:$step} 
       str_arr[$i]=${str:$[$step*$i]:$step}
    done
    echo ${str_arr[@]}
fi

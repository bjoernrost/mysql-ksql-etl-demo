#!/bin/bash

while true
do
PRICE=$(( ( RANDOM % 10 )  + 1 ))
USERID=$(( ( RANDOM % 42 ) +1 ))
arr[0]="olives"
arr[1]="olives"
arr[2]="diamonds"
arr[3]="knowledge"

rand=$[ $RANDOM % 4 ]
PRODUCT = ${arr[$rand]}
#echo $PRODUCT
#echo $PRICE
#echo $USERID
mysql code -e "INSERT INTO orders (product, price, user_id) VALUES ($PRODUCT, $PRICE, $USERID)"
sleep 0.1
done

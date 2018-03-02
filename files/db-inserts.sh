#!/bin/bash

while true
do
PRICE=$(( ( RANDOM % 10 )  + 1 ))
USERID=$(( ( RANDOM % 42 ) +1 ))
arr[0]="salt"
arr[1]="salt"
arr[2]="olives"
arr[3]="wine"

rand=$[ $RANDOM % 4 ]
PRODUCT=${arr[$rand]}
#echo $PRODUCT
#echo $PRICE
#echo $USERID
mysql code -e "INSERT INTO orders (product, price, user_id) VALUES (\"$PRODUCT\", $PRICE, $USERID)"
sleep 0.1
done

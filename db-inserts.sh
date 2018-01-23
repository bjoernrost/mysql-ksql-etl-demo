#!/bin/bash

while true
do
PRICE=$(( ( RANDOM % 10 )  + 1 ))
USERID=$(( ( RANDOM % 42 ) +1 ))
#echo $PRICE
#echo $USERID
mysql code -e "INSERT INTO orders (product, price, user_id) VALUES ('hello world', $PRICE, $USERID)"
sleep 0.1
done

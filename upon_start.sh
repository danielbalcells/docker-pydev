#! /bin/bash
exec jupyter notebook &> /dev/null &
while :
do
        sleep 100
done

#! /bin/bash
exec jupyter notebook --notebook-dir=/home/b.dbe/ &> /dev/null &
while :
do
        sleep 100
done

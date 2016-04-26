#! /bin/bash
# Usage: ./launch.sh code_dir container_name

if [[ -z $1 ]]; then codedir=/home/daniel/code; else codedir=$1; fi
if [[ -z $2 ]]; then containername=pydev; else containername=$2; fi


cmd="docker run -it --detach --net=host --name=$containername -P -p 80:80 -u daniel:daniel -v $codedir:/home/daniel/code danielbalcells/devel-python"
echo $cmd
$cmd

#! /bin/bash
# Usage: ./launch.sh ext_code_dir container_name

if [[ -z $1 ]]; then codedir=/Users/daniel/code; else codedir=$1; fi
if [[ -z $2 ]]; then containername=pydev; else containername=$2; fi


cmd="docker run --memory=4g -it --detach --net=host --name=$containername -P -p 80:80 -u daniel:daniel -v $codedir:/home/daniel/ext danielbalcells/pydev:latest"
echo $cmd
$cmd

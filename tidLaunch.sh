#! /bin/bash
# Usage: ./launch.sh code_dir container_name
DEFAULT_GPU_OPTS="--device /dev/nvidia0:/dev/nvidia0 \
        --device /dev/nvidia1:/dev/nvidia1 \
        --device /dev/nvidiactl:/dev/nvidiactl \
        --device /dev/nvidia-uvm:/dev/nvidia-uvm"
if [[ -z $1 ]]; then codedir=/mnt/8T-NAS/users/b.dbe; else codedir=$1; fi
if [[ -z $2 ]]; then containername=pydev; else containername=$2; fi
if [[ -z $3 ]]; then
        gpuopts=$DEFAULT_GPU_OPTS;
else
        gpuopts=$(cat $3);
fi

cmd="docker run -it --detach --net=host --name=$containername -P -p 80:80 \
        -u b.dbe:speech -v $codedir:/home/b.dbe/code \
        $gpuopts \
        danielbalcells/pydev:latest upon_start_tid.sh"
echo $cmd
$cmd

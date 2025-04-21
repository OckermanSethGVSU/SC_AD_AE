#!/bin/bash
#PBS -l select=1:system=polaris
#PBS -l walltime=02:00:00
#PBS -l place=scatter
#PBS -l filesystems=home:eagle
#PBS -q queue
#PBS -A account
#PBS -o seq.out
#PBS -e seq.err


# module use /soft/modulefiles 
# module load conda; conda activate
# conda activate dask


module use /soft/modulefiles 
module load conda; conda activate

conda activate index

module load spack-pe-base/0.7.1
module load spack-pe-base/0.8.1
module load gcc/11.4.0

num_worker=1
nodes=1

export NCCL_DEBUG=INFO
export NCCL_DEBUG_SUBSYS=ALL
export NCCL_DEBUG_FILE=./nccl_debug_${nodes}_${num_worker}.log
export NCCL_COLLNET_ENABLE=1
export NCCL_NET_GDR_LEVEL=PHB

total=$((num_worker * nodes))
NDEPTH=$((32 / num_worker))


cd unmodded_DCRNN_PyTorch/


# BAY
# python3 dcrnn_train_pytorch.py --config_filename=data/model/dcrnn_bay.yaml

python3 worker_monitor.py &

# allLA
python3 dcrnn_train_pytorch.py --config_filename=data/model/allLA.yaml

# PEMS
# python3 dcrnn_train_pytorch.py --config_filename=data/model/pems.yaml
# mv ../seq_${nodes}_${num_worker}.out . 
# mv ../seq_${nodes}_${num_worker}.err . 



DATE=$(date +"%Y-%m-%d_%T")
dir="seq_${DATE}"
mkdir -p $dir

cp -r model/ $dir
cp -r scripts/ $dir
cp -r lib/ $dir
cp data/model/*.yaml $dir
mv stats.txt $dir
mv per_epoch_stats.txt $dir
mv seq.out $dir
mv seq.err $dir
cp seq_submit.sh $dir



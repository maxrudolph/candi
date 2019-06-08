#!/bin/bash
#SBATCH --partition med2
#SBATCH --time 02:00:00
#SBATCH -N 1
#SBATCH --exclusive
#SBATCH --job-name=candi
set -x
#module purge
module load openmpi/4.0.1
which mpicc
HOME=`echo ~`
INSTALL_PREFIX=$HOME/sw/dealii-toolchain-openmpi-4.0.1-master
# build hdf5, p4est, trilinos, dealii:
yes | ./candi.sh --prefix=$INSTALL_PREFIX --packages="hdf5 p4est trilinos dealii" -j 32
# clean up:
rm -rf /tmp/build
rm -rf /tmp/src
rm -rf /tmp/unpack

# compile aspect
CANDI_DIR=`pwd`
rm -rf aspect
git clone https://github.com/geodynamics/aspect
mkdir aspect/build
mkdir /tmp/build
cd /tmp/build
cmake -DDEAL_II_DIR=${INSTALL_PREFIX}/deal.II-v9.0.1 ${CANDI_DIR}/aspect/
make release
make -j 32
cp aspect ${CANDI_DIR}/aspect/build/aspect.fast
make debug
make -j 32
cp aspect ${CANDI_DIR}/aspect/build/aspect.debug
cd ${CANDI_DIR}
rm -rf /tmp/build

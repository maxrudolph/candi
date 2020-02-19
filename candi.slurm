#!/bin/bash
#SBATCH --partition med2
#SBATCH --time 02:00:00
#SBATCH -N 1
#SBATCH --exclusive
#SBATCH --job-name=candi
#SBATCH --mail-type=ALL
#SBATCH --mail-user=maxrudolph@ucdavis.edu
set -x
#module purge
#module load openmpi/4.0.1
module unload openmpi
export PATH=/home/rudolph/sw/openmpi-4.0.2/bin:$PATH

which mpicc
HOME=`echo ~`
INSTALL_PREFIX=$HOME/sw/dealii-toolchain-openmpi-4.0.2-hdf5
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
cmake -DDEAL_II_DIR=${INSTALL_PREFIX}/deal.II-master ${CANDI_DIR}/aspect/
make release
make -j 32
cp aspect ${CANDI_DIR}/aspect/build/aspect.fast
make debug
make -j 32
cp aspect ${CANDI_DIR}/aspect/build/aspect.debug
cd ${CANDI_DIR}
rm -rf /tmp/build

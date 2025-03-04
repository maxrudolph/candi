#!/bin/bash
#SBATCH --account rudolphgrp
#SBATCH --partition high2
#SBATCH --time 24:00:00
#SBATCH -N 1
#SBATCH --exclusive
#SBATCH --job-name=candi

#SBATCH --mail-type=ALL
#SBATCH --mail-user=maxrudolph@ucdavis.edu
set -x
#module purge
#module load openmpi
#module load gcc
module list
which mpicc
which mpic++
which mpif90

# set compilers
export CC=`which mpicc`
export FC=`which mpif90`
export CXX=`which mpic++`
export FF=`which mpif77`
export MPI_CXX=`which mpic++`

HOME=`echo ~`

INSTALL_PREFIX=$HOME/sw/dealii-9.6.1-toolchain-openmpi-5.0.5

# build hdf5, p4est, trilinos, dealii:
yes | ./candi.sh --prefix=$INSTALL_PREFIX --packages="openblas sundials hdf5 netcdf p4est trilinos dealii" -j 32
# clean up:
rm -rf /tmp/build1
rm -rf /tmp/src1
rm -rf /tmp/unpack1

# compile aspect
CANDI_DIR=`pwd`
rm -rf aspect
git clone git@github.com:geodynamics/aspect.git
mkdir aspect/build
mkdir /tmp/build
cd /tmp/build
cmake -D DEAL_II_DIR=${INSTALL_PREFIX}/deal.II-v9.6.1/ ${CANDI_DIR}/aspect/
date
time make debugrelease
make -j 32
cp aspect ${CANDI_DIR}/aspect/build/aspect.fast
date
rm -rf /tmp/build

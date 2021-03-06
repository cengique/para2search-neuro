#! /bin/bash

#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash

# The following skips work46 because of Perl DB_File problems
## -q all.q@work01,all.q@work02,all.q@work03,all.q@work04,all.q@work05,all.q@work06,all.q@work07,all.q@work08,all.q@work09,all.q@work10,all.q@work11,all.q@work12,all.q@work13,all.q@work14,all.q@work15,all.q@work16,all.q@work17,all.q@work18,all.q@work19,all.q@work20,all.q@work25,all.q@work26,all.q@work27,all.q@work28,all.q@work29,all.q@work30,all.q@work31,all.q@work32,all.q@work33,all.q@work34,all.q@work35,all.q@work36,all.q@work37,all.q@work38,all.q@work39,all.q@work40,all.q@work41,all.q@work42,all.q@work43,all.q@work44,all.q@work45,all.q@work46,all.q@work47,all.q@work48,all.q@work49,all.q@work50,all.q@work51,all.q@work52,all.q@work53,all.q@work54,all.q@work55,all.q@work56,all.q@work57,all.q@work58,all.q@work59,all.q@work60,all.q@work61,all.q@work62

# This sge job script reads a designated row from the parameter file and executes
# genesis to process it. It uses a fast hashtable access to read the parameter 
# row from a database created with the par2db.pl script.
# Notice that, this script does not mark the row as processed in the original 
# parameter file. One needs to use checkMissing.pl script to find out which 
# rows are already done.
# The reason this script does not modify the parameter file is to avoid
# race conditions that occur when writing to the parameter file concurrently.

# Author: Cengiz Gunay <cgunay@emory.edu> 2005/06/29
# $Id: sge_perlhash_execcmd.sh,v 1.1 2013/08/02 18:46:48 cengiz Exp $

# Run this with:
# qsub -t 1:1310 ~/brute_scripts/sge_perlhash_execcmd.sh ./a.out myparams.par

# Need to source our own rc file. >:O
source $HOME/.bashrc

curdir=`pwd`

echo -n "Starting job $SGE_TASK_ID/$SGE_TASK_LAST from parameter file $2 at $HOSTNAME on "
date

if [ -z "$2" ]; then
   echo "Need to specify executable and parameter file."
   echo ""
   echo "Usage: "
   echo "   $0 executable parameter_file"
   exit -1
fi

trap exit INT

execfile=$1
parfile=$2

# Random delay to avoid deadlock only for the first batch of nodes
# Afterwards, the offsets should be preserved.
#if [[ $SGE_TASK_ID < 126 ]]; then
   #awk 'BEGIN {system("sleep " rand() * 20)}'
#fi

# Read parameter values.
PAR_ROW=`get_1par.pl $parfile $SGE_TASK_ID`

[ "$?" != "0" ] && echo "Cannot read parameter row $SGE_TASK_ID, ending." && exit -1;

# Run executable with parameters 
time $execfile $PAR_ROW

[ "$?" != "0" ] && echo "Run $execfile failed, terminating job!" && exit -1

echo "Ending job"
date


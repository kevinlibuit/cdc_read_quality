#!/bin/bash
set -e
set -o pipefail

HELP="
Trims raw read files from a specified BaseSpace project and generates read-quality metrics of the trimmed reads using run_assembly_readMetrics.pl. Output metrics will be averages of R1 and R2 reads combined.  

Assumes BaseSpace directory exists in home directory and is mounted to BaseSpace account.

If not, run: 
$ mkdir ~/BaseSpace
$ basemount ~/BaseSpace

...and follow prompts to properly mount BaseSpace profile to the new directory.


A sym link for read files (fastq.gz) within a BaseSpace project will be made in ./<output_dir>/raw_reads/.
Final <project_id>cleaned_readMetrics.tsv will be placed within the output_dir.

NOTE: <output_dir> = project_id


###################
Usage:

clean_read_quality.sh -p <BaseSpace_project> -gs <genome_size>

-p: name of the BaseSpace project with reads of interest
-gs: expected size of genome in bp

"





while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "$HELP"
                        exit 0
                        ;;
                -p)
                        shift
                        if test $# -gt 0; then
                                project_id=$1
                        else
                                echo "no project specified"
                                exit 1
                        fi
                        shift
                        ;;
                --project-id*)
                        project_id=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                -gs)
                        shift
                        if test $# -gt 0; then
                                genome_size=$1
                        else
                                echo "genome size specified"
                                exit 1
                        fi
                        shift
                        ;;
                --genome_size*)
                        genome_size=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;

                *)
                        break
                        ;;
        esac
done


ERROR="ERROR:: No readMetrics genreated. See message above or use clean_metrics.sh-h for more info."

#Link basespace reads to project_dir
link_reads_from_bsproj.sh -i ${project_id} -o ${project_id}


#set variables for raw/clean read directories
raw_read_dir="${project_id}/raw_reads/"
mkdir ${project_id}/clean
clean_read_dir="${project_id}/clean/"


#Shuffle and clean all reads within project
for i in ${raw_read_dir}/*R1_001.fastq.gz
do 
  b=`basename $i _R1_001.fastq.gz`
  run_assembly_shuffleReads.pl ${raw_read_dir}/${b}_R1_001.fastq.gz ${raw_read_dir}/${b}_R2_001.fastq.gz > ${clean_read_dir}/${b}.fastq
  run_assembly_trimClean.pl -i ${clean_read_dir}/${b}.fastq -o ${clean_read_dir}/${b}_cleaned.fastq.gz --nosingletons
  rm ${clean_read_dir}/${b}.fastq >& ${clean_read_dir}/cleaning.log
done  

#Get read-quality metrics for all cleaned reads
if ls ${clean_read_dir}/*_cleaned.fastq.gz 1> /dev/null 2>&1;
then
  echo "Gettig quality metrics..."
  run_assembly_readMetrics.pl ${clean_read_dir}/*fastq.gz --fast -e ${genome_size} > ${project_id}/${project_id}_cleaned_readMetrics.tsv
  echo "Done! Quality metrics have been saved to ${project_id}/${project_id}_readMetrics.tsv and can be veiwed in Microsoft Excel."
else
  echo ${ERROR}
fi

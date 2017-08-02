#!/bin/bash
set -e
set -o pipefail


HELP="
Generates read-quality metrics using run_assembly_readMetrics.pl from the CDC CG-Pipeline for reads in a specified BaseSpace project. 

Assumes BaseSpace directory exists in home directory and is mounted to BaseSpace account.

If not, run: 
$ mkdir ~/BaseSpace
$ basemount ~/BaseSpace

...and follow prompts to properly mount BaseSpace profile to the new directory.

A sym link for read files (fastq.gz) within a BaseSpace project will be in <output_dir>/raw_reads/.

Final <project_id>_readMetrics.tsv will be placed within the output_dir.


Usage:

cdc_qual_metrics.sh -p <BaseSpace_project>

-p: name of the BaseSpace project with reads of interest

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
                *)
                        break
                        ;;
        esac
done

ERROR="ERROR:: No readMetrics genreated. See message above or use cdc_qual_metrics -h for more info."

#Link reads to output_dir
echo "Linking reads from BaseSpace Proejct... "
link_reads_from_bsproj.sh -i ${project_id} -o ${project_id}


if ls ${project_id}/raw_reads/*.fastq.gz 1> /dev/null 2>&1;
then
  echo "Getting quality metrics..."
  run_assembly_readMetrics.pl --fast ${project_id}/raw_reads/*.fastq.gz -e 5000000 | sort -k3,3n > ${project_id}/${project_id}_readMetrics.tsv
  echo "Done! Quality metrics are in ${project_id}/${project_id}_readMetrics.tsv and can be viewed in Microsoft Excel." 
else
  echo ${ERROR}
fi




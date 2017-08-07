#!/bin/bash

HELP="
Create sym link for read files (fastq.gz) in BaseSpace project to a specified directory. Assumes BaseSpace directory exists in home directory and is mounted to BaseSpace account.

If not, run: 
$ mkdir ~/BaseSpace
$ basemount ~/BaseSpace

Follow prompts to properly mount BaseSpace profile to the new directory.

Usage:

link_reads_from_bsproj.sh -i <BaseSpace_project> -o <output_directory>

-i: name of the BaseSpace project with reads of interest
-o: name of the directory in which sym links will be created
"

while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "$HELP"
                        exit 0
                        ;;
                -i)
                        shift
                        if test $# -gt 0; then
                                input_dir=$1
                        else
                                echo "no input specified"
                                exit 1
                        fi
                        shift
                        ;;
                --input*)
                        input_dir=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                -o)
                        shift
                        if test $# -gt 0; then
                                output_dir=$1
                        else
                                echo "no output dir specified"
                                exit 1
                        fi
                        shift
                        ;;
                --output-dir*)
                        output_dir=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

if ls ~/BaseSpace/Projects/${input_dir}/Samples/*/Files/*.fastq.gz 1> /dev/null 2>&1; 
then
  mkdir ${output_dir}/raw_reads -p
  ln -s ~/BaseSpace/Projects/${input_dir}/Samples/*/Files/*.fastq.gz ${output_dir}/raw_reads/
  echo "Reads from BaseSpace project ${input_dir} have been linked linked to ${output_dir}/raw_reads/."

else
  echo "ERROR:: No read files found in BaseSpace project ${input_dir}. Please enter valid BaseSpace project and ensure ~/BaseSpace is properly mounted"
  exit 1
fi



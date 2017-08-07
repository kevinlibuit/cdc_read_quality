# cdc_read_quality
Generates read-quality metrics using run_assembly_readMetrics.pl from the CDC CG-Pipeline for reads in a specified BaseSpace project.

Dependencies: <br/>
[CG-Pipeline](https://github.com/lskatz/CG-Pipeline), [BaseMount](https://basemount.basespace.illumina.com/)

## Usage<br/>

Get quality metrics on raw read files:
```
$ raw_read_quality.sh -p <BaseSpace Project_id> - e <genome_size>
```
Shuffle and trim files first, then get quality metrics:
```
$ clean_read_quality.sh -p <BaseSpace Project_id> - e <genome_size>
```

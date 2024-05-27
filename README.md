# DaRT Processing

Directory containing scripts needed for processing DaRT data.

## Scripts

The `scripts` directory has each script used in this project numbered by the order in which it was run.
The main scripts to become familiar with include:

- [05-create-ipyrad-samples-and-popmap-files.R][05]: This script can help create sample lists and population map files.
- [06-ipyrad-create-params-file.sh][06]: A simple script containing the code to create an `Ipyrad` parameters file.
- [07-ipyrad-steps-1_2.sh][07]: The code needed to run the first two steps of the `Ipyrad` pipeline.
- [08-ipyrad-create-branch.sh][08]: An example of how to create a branched dataset.
- [09-ipyrad-steps-3_7-for-branched-data.sh][09]: A script to run the remaining steps (3-7) on the branched data.

## Results

Contains the QC-report (`multiqc_report.html`) for all processed samples and sequence-statistic files for
both the raw and trimmed data. These sequence statistics files are what are used to generate additional
custom QC figures/tables in the R-script [04-qc-visualisation.R][04].

## Data

The `data` directory contains the DaRT target CSV files, in addition to a `popmap-files` directory. I've put a couple
of example files in the `popmap-files` directory for the *Aipysurus* dataset.

[04]: https://github.com/a-lud/dart-analyses/blob/main/scripts/04-qc-visualisation.R
[05]: https://github.com/a-lud/dart-analyses/blob/main/scripts/05-create-ipyrad-samples-and-popmap-files.R
[06]: https://github.com/a-lud/dart-analyses/blob/main/scripts/06-ipyrad-create-params-file.sh
[07]: https://github.com/a-lud/dart-analyses/blob/main/scripts/07-ipyrad-steps-1_2.sh
[08]: https://github.com/a-lud/dart-analyses/blob/main/scripts/08-ipyrad-create-branch.sh
[09]: https://github.com/a-lud/dart-analyses/blob/main/scripts/09-ipyrad-steps-3_7-for-branched-data.sh
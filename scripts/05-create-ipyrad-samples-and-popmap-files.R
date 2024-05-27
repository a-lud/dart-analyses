# --------------------------------------------------------------------------- #
# Build population files from metadata
suppressPackageStartupMessages({
    library(tidyverse)
})

# Read in meta-data file created in the 'qc-visualisation.R' script
df.samples <- read_csv(
    'data/240524-sample-linkage-readCounts.csv',
    col_types = cols()
)

# CHANGE: list the species' you want to keep here
species <- c('laevis', 'pooleorum')

# CHANGE: What do you want the filename prefix to be? Example below creates:
#   - ALA-APO-samples.txt
#   - ALA-APO-popmap.txt
output_file_basename <- 'ALA-APO'

# --------------------------------------------------------------------------- #
# Create output directory
fs::dir_create('data/popmap-files', recurse = TRUE)

# --------------------------------------------------------------------------- #
# Create samples file and population map file

# List of samples
df.samples |>
    filter(Country != 'Denmark', Species %in% species ) |>
    arrange(sample_id, -read_count) |>
    # Group by sample
    group_by(sample_id) |>
    # Keep the sequencing run with the most data
    slice(1) |>
    pull(id) |>
    unique() |>
    write_lines(file = paste0("data/popmap-files", output_file_basename, "-samples.txt"))

# Population map
df.samples |>
    filter(Country != 'Denmark', Species %in% species) |>
    arrange(sample_id, -read_count) |>
    group_by(sample_id) |>
    slice(1) |>
    ungroup() |>
    # Two column file
    select(id, Region) |>
    mutate(Region = str_replace_all(Region, ' ', '_')) |>
    write_delim(
        paste0("data/popmap-files", output_file_basename, "-popmap.txt"),
        col_names = FALSE,
        delim = ' '
    )

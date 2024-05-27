# --------------------------------------------------------------------------- #
# Sample assessment
suppressPackageStartupMessages({
    library(tidyverse)
    library(fs)
    library(jsonlite)
})

options(scipen = 999)

# --------------------------------------------------------------------------- #
# Metadata
df.samples <- read_csv(
    'data/240524-sample-linkage.csv',
    col_types = cols()
) |>
    # Remove elegans sample
    filter(!str_detect(id_clean, 'KLS1121'))

# --------------------------------------------------------------------------- #
# Import QC data

# Raw read counts - not all files were raw...
df.raw.statistics <- read_tsv(
    'results/qc/sequence-statistics/raw.tsv',
    col_types = cols()
) |>
    mutate(file = str_remove(basename(file), '.FASTQ.gz')) |>
    select(id = file, raw_reads = num_seqs, raw_bases = sum_len) |>
    filter(!str_detect(id, 'KLS1121'))

df.trim.statistics <- read_tsv(
    'results/qc/sequence-statistics/trim.tsv',
    col_types = cols()
) |>
    mutate(file = str_remove(basename(file), '.fastq.gz')) |>
    select(id = file, trim_reads = num_seqs, trim_bases = sum_len) |>
    filter(!str_detect(id, 'KLS1121'))

# Bit of cleaning
df.statistics <- left_join(df.raw.statistics, df.trim.statistics) |>
    pivot_longer(names_to = 'measure', values_to = 'values', 2:5) |>
    separate(measure, into = c('data_state', 'data_type'), sep = '_') |>
    mutate(
        sample_id = sub('-[^-]+$', '', id),
        species_id = str_split_i(id, '-', 1),
        # We make these columns factors to maintain the order (order is defined by the levels)
        species_id = factor(species_id, levels = c('ALA', 'HMA', 'HST', 'APO', 'ATE')),
        data_type = factor(data_type, levels = c('reads', 'bases')),
        data_state = factor(data_state, levels = c('raw', 'trim')),
    )

# --------------------------------------------------------------------------- #
# Write metadata with addition of trimmed read counts
df.statistics |>
    filter(data_state == 'trim', data_type == 'reads') |>
    select(id, sample_id, read_count = values, -c(data_state, data_type, species_id)) |>
    left_join(df.samples, by = join_by(id == id_clean)) |>
    write_csv('data/240524-sample-linkage-readCounts.csv')

# --------------------------------------------------------------------------- #
# Loss of reads/bases - some samples did not have raw files and will skew
# the results

# Boxplots of reads/bases before/after trimming
df.statistics |>
    ggplot(
        aes(
            x = data_state,
            y = values,
            fill = data_state
        )
    ) +
    geom_boxplot() +
    theme_bw() +
    facet_grid(rows = vars(data_type), cols = vars(species_id), scales = 'free_y')

# Loss of reads/bases per sample
p.reads.bases.lost.point <- df.statistics |>
    ggplot(aes(x= id, y= values, group = id, color = data_state)) +
    geom_line(colour = 'grey90', linewidth = 0.2) +
    geom_point(size=2, alpha = 0.8) +
    theme_bw() +
    scale_colour_manual(values = c('#ff99c8', '#a9def9')) +
    scale_y_continuous(labels = scales::label_number(scale = 1e-6, suffix = 'M')) +
    facet_grid(
        rows = vars(data_type),
        cols = vars(species_id),
        scales = 'free',
        space = 'free_x'
    ) +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 0.98, vjust = 0.5),
        panel.grid.major = element_blank()
    )
plotly::ggplotly(p.reads.bases.lost.point)

# --------------------------------------------------------------------------- #
# Relationship between read count and usable bases - should be linear
df.statistics |>
    pivot_wider(names_from = data_type, values_from = values) |>
    filter(data_state == 'trim') |>
    ggplot(aes(x = reads, y = bases)) +
    geom_point() +
    scale_y_continuous(labels = scales::label_number(scale = 1e-6, suffix = 'M')) +
    scale_x_continuous(labels = scales::label_number(scale = 1e-6, suffix = 'M')) +
    theme_bw() +
    facet_wrap(vars(species_id), nrow = 2)

# --------------------------------------------------------------------------- #
# Histogram of read lengths - two distinct peaks
df.statistics |>
    filter(data_state == 'trim', data_type == 'reads') |>
    ggplot(aes(x = values)) +
    geom_histogram(bins = 50, fill = 'grey80') +
    scale_x_continuous(labels = scales::label_number(scale = 1e-6, suffix = 'M')) +
    theme_bw()

# --------------------------------------------------------------------------- #
# Filter for good samples: Samples with >= N-reads
df.reads.bases |>
    filter(data == 'filtered', group == 'reads') |>
    arrange(id, -values) |>
    mutate(sample_id = sub('-[^-]+$', '', id)) |>
    group_by(sample_id) |>
    # Choose sample with highest number of reads if there are replicates
    # or if sample was sequenced across multiple runs.
    slice(1) |>
    # Apply minimum read count threshold
    filter(values > 1e6)


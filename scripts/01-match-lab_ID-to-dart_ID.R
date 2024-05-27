# --------------------------------------------------------------------------- #
# Libraries we need
suppressPackageStartupMessages({ library(tidyverse) })

# Curated sample-sheet
df.samples <- read_csv(
    'data/2024-05-24 sample master sheet.csv',
    col_types = cols()
) |>
    mutate(
        `Order no.` = ifelse(
            str_detect(`Order no.`, 'Dn'),
            str_replace(`Order no.`, 'Dn', 'DN'),
            `Order no.`
        )
    )

# Remove samples that failed QC
ids.remove <- df.samples |>
    filter(Notes == 'failed qc') |>
    pull(id)

# Also remove the sample that was listed as two separate species
ids.remove <- c('KLS0819', ids.remove)

# Number of UNIQUE samples: 280
df.samples <- df.samples |>
    filter(! id %in% ids.remove) |>
    select(`Order no.`, id, Genus, Species, Region, Country) |>
    distinct(`Order no.`, id, .keep_all = TRUE)

# Sequenced twice
# KLS1204         2
# KLS1206         2
# R29880          2
# SS170816-01     2
df.samples |>
    count(id) |>
    filter(n > 1)

samples <- unique(df.samples$id)

# --------------------------------------------------------------------------- #
# Filter DaRT sample sheets to get only samples that pass/haven't got messed
# up species ID.
fs::dir_ls(
    path = "data",
    glob = "*targets*.csv",
    recurse = TRUE
) |>
    read_csv(col_types = cols()) |>
    select(
        `Order no.` = ordernumber, dart_id = targetid,
        id = genotype, barcode9l, barcode
    ) |>
    # 348 Rows after removing problematic samples
    filter(id %in% samples) |>
    # Re-join with df.samples to add meta-data back in
    left_join(df.samples) |>
    # Make 3-letter species ID
    mutate(tl = toupper(paste0(substr(Genus, 1,1), substr(Species, 1,2)))) |>
    # Build unique ID using: 3-letter, id and dart_id
    unite(col = id_clean, sep = '-', tl, id, dart_id, remove = FALSE) |>
    # Replace white-space with hyphen
    mutate(id_clean = str_replace(id_clean, ' ', '-')) |>
    select(order = `Order no.`, dart_id, id_clean, barcode9l, barcode, Genus, Species, Region, Country) |>
    write_csv('data/240524-sample-linkage.csv')


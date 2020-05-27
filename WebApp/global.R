# Search type options (search by gene or by TF)
search_options <- c("Gene", "TF")

# Range type options (for filtering based on correlation)
range_type_options <- c("Inside range", "Outside range")

# Specify column labels for the Shiny datatable object
dt_column_labels <- c("Target Gene", "Transcription Factor", "Correlation", "P-value", "Q-value", "R2")

# Specify order of columns in data (i.e. the dataframe)
df_column_order <- c("targetGene", "TF", "Cor", "P", "Q", "RSquared")

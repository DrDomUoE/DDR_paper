# Load necessary libraries
library(pheatmap)
library(RColorBrewer)
# Manually define input file and max_val
input_file <- "TLS.output.tsv.txt"  # Replace with the actual file path
max_val <- 2000  # Replace with the actual value for truncating heatmap values. this is where the value you decide on after running hist_sript.R goes
# Define the width of the PDF (modify based on your needs)
width_pdf <- 10
# Create the output file name
output_filename <- paste(input_file, ".heatmap.pdf", sep="")
# Read the table from the input file (ensure it's tab-separated with .tsv)
HM_data <- read.table(input_file, header=TRUE, row.names=1, sep="\t")
# Extract main heatmap data (assumed rows 3 to 41 are the main data rows)
HM_data_HM <- HM_data[3:20, ]
# Order HM data by the number of NA cells
HM_data_HM_add_na <- cbind(HM_data_HM, rowSums(is.na(HM_data_HM)))
HM_data_HM_add_na <- HM_data_HM_add_na[order(HM_data_HM_add_na[, ncol(HM_data_HM_add_na)]), ]
HM_data_HM_ord <- HM_data_HM_add_na[, -ncol(HM_data_HM_add_na)]  # Remove the NA count column
# Truncate values above max_val
HM_data_HM_ord[HM_data_HM_ord > max_val] <- max_val
# Extract lifestage and code it
lifestage_data_t <- t(lifestage_data)
lifestage_data_t_coded <- data.frame(Lifestyle = ifelse(lifestage_data_t == 1, "Free living",
                                                        ifelse(lifestage_data_t == 2, "Extracellular",
                                                               ifelse(lifestage_data_t == 3, "Cytoplasmic", "Intranuclear"))))
# Extract mitochondrial and plastid status and code it
MPS_data <- HM_data[2, ]
MPS_data_t <- t(MPS_data)
MPS_data_t_coded <- data.frame(Mitocondrial_plastid_status = ifelse(MPS_data_t == 1, "Plastid & ATP-producing mitochondria", "No ATP-producing mitochondria"))
# Combine the annotations into one data frame
annotation_data <- cbind(lifestage_data_t_coded, MPS_data_t_coded)
# Set heatmap colors
hmcol <- colorRampPalette(brewer.pal(3, "BuPu"))(256)
# Set the lifestyle colors
my_colour <- list(
  "Lifestyle" = c("Free living" = "cornsilk3", "Extracellular" = "lightgreen",
                  "Cytoplasmic" = "orange1", "Intranuclear" = "purple1"),
  "Mitochondrial_plastid_status" = c("Plastid & ATP-producing mitochondria" = "burlywood3", "No ATP-producing mitochondria" = "beige")
)
# Produce the heatmap and save it to a PDF
pdf(output_filename, width = width_pdf)
pheatmap(t(HM_data_HM_ord), cluster_rows = FALSE, cluster_cols = FALSE, color = hmcol,
         annotation_row = annotation_data, annotation_colors = my_colour,
         fontsize = 6, cellwidth = 8, na_col = "white")
dev.off()
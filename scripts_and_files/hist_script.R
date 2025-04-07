# Manually define the arguments when working in RStudio or R Console
#this file will give you a an idea of the cut off number for the longest protein to use in heatmap_script.R
input_file <- "TLS.output.tsv.txt" #this is where you manually write the file name you want to analyse
column_to_hist <- "Homo"
# Now continue with the script as usual

hist_data <- read.table(input_file, header=TRUE, row.names=1)
output_hist_file <- paste(input_file, ".hist.pdf", sep="")
pdf(output_hist_file)

hist(hist_data[[column_to_hist]], breaks=100, col="grey")
dev.off()

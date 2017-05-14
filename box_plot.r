#!/usr/bin/Rscript

library(plyr)
library(ggplot2)
library(plotly)

args = commandArgs(trailingOnly=TRUE)

#path to commits_info.tsv file
path = args[1] 

#path to file in metaquast output folder
postfix = args[2]

inputDataframe = cbind.data.frame(read.delim(path, header = TRUE, stringsAsFactors = FALSE))
inputDataframe$path <- file.path(inputDataframe$path, postfix)

#iterate over all assembly results and combine all quast results (transposed_report.tsv)
fillDataset <- function(paths) {
   for (assembler in paths) {
    files <- list.files(path=assembler, pattern="^transposed_report.tsv", include.dirs=F, full.names=T, recursive=T)
    lapply(files, function(file) {
        if (!exists("dataset")) {
       	   dataset <- cbind.data.frame(read.delim(file, header=TRUE, stringsAsFactors=FALSE))
	   dataset$path = file
          } else {
           temp_dataset <- cbind.data.frame(read.delim(file, header=TRUE, stringsAsFactors=FALSE))
           temp_dataset$path = file
           dataset <- rbind.fill(list(dataset, temp_dataset))
          }
        dataset <<- dataset[!grepl("broken", dataset$Assembly),]
        dataset
   })
 }
}

fillDataset(inputDataframe$path)
final_dataset <- merge(inputDataframe, dataset, by=c("path"), all.y=T)

#build the plot with ggplot
p <- ggplot(data=final_dataset, aes(x=reorder(Assembly, Genome.fraction....), y=Genome.fraction...., fill=Assembly) ) + 
	geom_boxplot() + 
        geom_point() +
	coord_flip() +
	labs(x = "Assemblers",
	    y = "Genome Fraction (%)",
	    fill = "Assemblers")

pl <- ggplotly(p)

#write html file to output and copy bioboxes.yaml that descibes the produced out.html file
htmlwidgets::saveWidget(pl,'/output/out.html')
system("cp /project/biobox.yaml /output")

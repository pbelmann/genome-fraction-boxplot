#!/usr/bin/Rscript

library(plyr)
library(ggplot2)
library(plotly)

args = commandArgs(trailingOnly=TRUE)

#path to commits_info.tsv file
path = args[1]

#path to file in metaquast output folder
postfix = args[2]

#path to additional files
additional_files_path = args[3]

additional_files_dataframe = cbind.data.frame(read.delim(additional_files_path, header = TRUE, stringsAsFactors = FALSE))

group_path = additional_files_dataframe[additional_files_dataframe$id=="group"][["path"]]

genomes_group_dataframe = cbind.data.frame(read.delim(group_path, header = TRUE, stringsAsFactors = FALSE))


inputDataframe = cbind.data.frame(read.delim(path, header = TRUE, stringsAsFactors = FALSE))
inputDataframe$path <- file.path(inputDataframe$path, postfix)

#iterate over all assembly results and combine all quast results (transposed_report.tsv)
fillDataset <- function(paths) {
  for (assembler in paths) {
    #files <- list.files(path=assembler, pattern="^transposed_report.tsv", include.dirs=F, full.names=T, recursive=T)
    genome_dirs <- list.files(path=assembler, pattern="*", include.dirs=F, full.names=F, recursive=F)
    lapply(genome_dirs, function(genome_dir) {
      file <- file.path(assembler, genome_dir, "transposed_report.tsv")
      if (!exists("dataset")) {
        dataset <- cbind.data.frame(read.delim(file, header=TRUE, stringsAsFactors=FALSE))
        dataset$path = assembler
        dataset$genome_path = genome_dir
      } else {
        temp_dataset <- cbind.data.frame(read.delim(file, header=TRUE, stringsAsFactors=FALSE))
        temp_dataset$path = assembler
        temp_dataset$genome_path = genome_dir
        dataset <- rbind.fill(list(dataset, temp_dataset))
      }
      dataset <<- dataset[!grepl("broken", dataset$Assembly),]
      dataset
    })
  }
}

fillDataset(inputDataframe$path)
dataset <- merge(dataset, genomes_group_dataframe, by.x=c("genome_path"), by.y= c("path"))
final_dataset <- merge(dataset, inputDataframe, by=c("path"), all.x=T)

create_plot <- function(dataframe, path){
  #build the plot with ggplot
  p <- ggplot(data=dataframe, aes(x=reorder(name, Genome.fraction....), y=Genome.fraction...., fill=name)) + 
    geom_boxplot() + 
    geom_point() +
    coord_flip() +
    labs(x = "Assemblers",
         y = "Genome Fraction (%)",
         fill = "Assemblers")
  pl <- ggplotly(p)
  htmlwidgets::saveWidget(pl,path)
}

create_plot(final_dataset[final_dataset$group=="strain",], '/output/strain_out.html')

create_plot(final_dataset[final_dataset$group=="uniq",], '/output/uniq_out.html')

create_plot(final_dataset[final_dataset$group=="circular_elem",], '/output/circular_out.html')


#write html file to output and copy bioboxes.yaml that descibes the produced out.html file
system("cp /project/biobox.yaml /output")
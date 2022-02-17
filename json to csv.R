library(jsonlite)
library(data.table)
library(dplyr)
library(plyr)
library(tidyverse)

setwd("~/Desktop")
parent.folder <- "~/Desktop/raw by name"
sub.folder <- list.dirs(parent.folder,recursive = TRUE)[-1]


for (i in 1:length(sub.folder)){
  wb = list.files(path = sub.folder[i],
                     pattern = "*.json",
                     recursive = TRUE,
                     full.names = T)
  
  dflist <- list()
  name <- list()
  
  for (k in wb) {
    name[k] = strsplit(strsplit(strsplit(k,"/")[[1]][7],"_")[[1]][1],"-")
    dflist[[k]] = cbind(name[k], data.table(fromJSON(k,flatten = TRUE)[["search_results"]]))
  }
  
  
  new_list <- rbind.fill(lapply(dflist, function(x){as.data.frame(x,stringsAsFactors=FALSE)})) %>%
    unnest_wider(V1) %>%
    unnest_longer(categories) %>%
    unnest_wider(prices,names_repair = 'unique') %>%
    unnest_wider(symbol,names_sep = "_",names_repair = 'unique')%>%
    unnest_wider(value,names_sep = "_",names_repair = 'unique')%>%
    unnest_wider(currency,names_sep = "_",names_repair = 'unique')%>%
    unnest_wider(raw,names_sep = "_",names_repair = 'unique')%>%
    unnest_wider(name,names_sep = "_",names_repair = 'unique')%>%
    unnest_wider(is_primary,names_sep = "_",names_repair = 'unique')%>%
    unnest_wider(is_rrp,names_sep = "_",names_repair = 'unique')
  
  colnames(new_list)[1:4] <- c("Year","Month","Day","Time")
  colnames(new_list) <- gsub("\\.+", "_",colnames(new_list))
  
  write.csv(new_list, file = paste(basename(sub.folder[i]),'.csv',sep = ''))
}


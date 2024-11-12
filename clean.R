setwd("/Users/corydonbaylor/Documents/github/lifesciences_neo4j")
library(tidyverse)

genes = read_tsv("data/HCT116.tsv")

# we are going to format the data so that we can create a PPI network
# we are going to use uniprot as this apparently is the best ID
proteins = genes %>%
  select(UniprotA)%>%
  distinct()

length(unique(genes$UniprotA))

write.csv(proteins, "nodes.csv")
write.csv(genes, "relationships.csv")

# Search type options (search by gene or by TF)
search_options <- c("Gene", "TF")

# Range type options (for filtering based on correlation)
range_type_options <- c("Inside range", "Outside range")

# Specify column labels for the Shiny datatable object
dt_column_labels <- c("Target Gene", "Transcription Factor", "Correlation", "P-value", "Q-value", "R2")

# Specify order of columns in data (i.e. the dataframe)
df_column_order <- c("targetGene", "TF", "Cor", "P", "Q", "RSquared")

#### FUNCTIONS FOR ENRICHMENT TEST ###########

getTF <- function(trn, geneA)
{
  temp <- subset(trn, TF == geneA)
  temp[order(temp$Cor, decreasing=TRUE),]
}

# Enrichment Test
# Reference: https://www.pathwaycommons.org/guide/primers/statistics/fishers_exact_test/
EnrichFisher <- function(NSigGenes, NTotalGenes, SigInGroup, GroupSize){
  if(SigInGroup > GroupSize || SigInGroup > NSigGenes){
    stop("Significant Genes in Group Larger than Significant genes or gene list")
  }

  if(NSigGenes > NTotalGenes){
    stop("Sig Genes > Total Genes")
  }

  if(SigInGroup > NTotalGenes){
    stop("Sig In Group > Total Genes")
  }
  if(GroupSize > NTotalGenes){
    stop("Group Size > Total Genes")
  }

  a <- SigInGroup
  b <- NSigGenes - SigInGroup
  c <- GroupSize - SigInGroup
  d <- NTotalGenes - b
  mat <- (matrix(c(a, b, c, d), nrow=2))
  fisher.test(mat)$p.value
}

# Create Data frame and perform Fishers Exact Test
TFTableFunction <- function(data, gene.list, ModuleMin, ModuleMax, MinSigGenes){
  TFTable <- as.data.frame(table(data$TF))
  colnames(TFTable) <- c("TF", "NTargets")
  TFTable$SigGenes <- NA

  for(i in 1:dim(TFTable)[1])
  {
    x <- getTF(data, as.character(TFTable$TF[i])) # Pull out ALL The TFs
    dim(x)[1] == TFTable$NTargets[i] # This should be equal
    # How many in the input gene list match this TF?
    TFTable$SigGenes[i] <- length(intersect(as.character(x$targetGene), gene.list))
  }

  TFTable$FisherTest <- NA

  # Filter By Preset Thresholds
  TFTable <- subset(TFTable, NTargets >= ModuleMin)
  TFTable <- subset(TFTable, NTargets < ModuleMax)
  TFTable <- subset(TFTable, SigGenes >= MinSigGenes)

  if(dim(TFTable)[1] < 1) return(TFTable)

  for(i in 1:length(TFTable$TF)){
    TFTable$FisherTest[i] <- EnrichFisher(NSigGenes=as.numeric(length(gene.list)), NTotalGenes=9565,
                                          SigInGroup =TFTable$SigGenes[i], GroupSize=TFTable$NTargets[i])
  }

  TFTable$FisherAdjustP <- p.adjust(TFTable$FisherTest, method="BH", n=dim(TFTable)[1])
  TFTable <- TFTable[order(TFTable$FisherAdjustP, decreasing=F),]

  # Relabel rows sequentially from 1 and return
  rownames(TFTable) <- 1:nrow(TFTable)
  TFTable
}


###### Load Data ##############
##Load Model (Pulled from what should work out of github)
setwd("~/Documents/GitHub/PlacentalTRN/WebApp")
file_name <- "Data/Placental_Gene_TF_Associations.csv"
data <- read.csv(file_name)

# Load TF/gene association data (assumes file is in same location as server.R)
# Also, load R-squared table and merge with TF/Gene association data
#file_data <- reactive({

  # TF/Gene association data
  file_name <- "Data/Placental_Gene_TF_Associations.csv"
  data <- read.csv(file_name)

  # Target gene R-squared data
  file_name <- "Data/Target_Gene_Rsquared.csv"
  rsquared <- read.csv(file_name)

  # Left-join TF/Gene association data with R-squared data
  data <- left_join(data, rsquared, by = 'targetGene')



#2 Example Gene Lists (.txt files)
  #load("/Users/alisonpaquette/Dropbox/PlacentalTRNProject/Nov2019_ResultsforPaper/PTBAssocations/GeneLists/AggregatedMicroarraySig_BOR2017.RData")
#Example1<-write.table(as.character(Microarray_sig$hgnc_symbol),file="/Users/alisonpaquette/Dropbox/PlacentalTRNProject/Nov2019_ResultsforPaper/PTBAssocations/GeneLists/Example1_MicroarrayData.txt")

Example1<-read.table("/Users/alisonpaquette/Dropbox/PlacentalTRNProject/Nov2019_ResultsforPaper/PTBAssocations/GeneLists/Example1_MicroarrayData.txt")
Example1<-as.character(Example1[,1])


Example2<-read.table("/Users/alisonpaquette/Dropbox/PlacentalTRNProject/Nov2019_ResultsforPaper/PTBAssocations/GeneLists/Example2_RNASeqData.txt")
Example2<-as.character(Example2[,1])

###### Functions ##############################################################

# pull out the top target Genes for a given TF

#NOTE: This is the original function; should be analogous to: tf_filtered_results

getTF <- function(trn, geneA)
{
  temp <- subset(trn, TF == geneA)
  temp[order(temp$Cor, decreasing=TRUE),]
}

#### NEW FUNCTIONS FOR ENRICHMENT TEST ###########

# 1. Enrichment Test
# Reference: https://www.pathwaycommons.org/guide/primers/statistics/fishers_exact_test/

EnrichFisher <-function(NSigGenes,NTotalGenes,SigInGroup,GroupSize){
  if(SigInGroup>GroupSize || SigInGroup>NSigGenes){
    stop("Significant Genes in Group Larger than Significant genes or gene list")
  }
  if(NSigGenes>NTotalGenes){
    stop("Sig Genes > Total Genes")
  }
  if(SigInGroup>NTotalGenes){
    stop("Sig In Group > Total Genes")
  }
  if(GroupSize>NTotalGenes){
    stop("Group Size > Total Genes")
  }

  a=SigInGroup
  b=NSigGenes-SigInGroup
  c=GroupSize-SigInGroup
  d=NTotalGenes-b
  mat<-(matrix(c(a,b,c,d),nrow=2))
  fisher.test(mat)$p.value
}


#2. Create Data frame Perform Fishers Exact Test
TFTableFunction<-function(data,gene.list,ModuleMin,ModuleMax,MinSigGenes){
TFTable<-as.data.frame(table(data$TF))
colnames(TFTable)<-c("TF","NTargets")
TFTable$SigGenes<-NA
for(i in 1:dim(TFTable)[1])
{
  x<-getTF(data,as.character(TFTable$TF[i])) # Pull out ALL The TFs
  dim(x)[1]==TFTable$NTargets[i] #This should be equal
  TFTable$SigGenes[i]<-length(intersect(as.character(x$targetGene),gene.list)) #How many in the input gene list match this TF?
}

# Filter By Preset Thresholds
TFTable<-subset(TFTable,NTargets>=ModuleMin)
TFTable<-subset(TFTable,NTargets<ModuleMax)
TFTable<-subset(TFTable,SigGenes>=MinSigGenes)
TFTable$FisherTest<-NA
for(i in 1:length(TFTable$TF)){
  TFTable$FisherTest[i]<-EnrichFisher(NSigGenes=as.numeric(length(gene.list)),NTotalGenes=9565,SigInGroup =TFTable$SigGenes[i],GroupSize=TFTable$NTargets[i])
}
TFTable$FisherAdjustP<-p.adjust(TFTable$FisherTest,method="BH",n=dim(TFTable)[1])
TFTable[order(TFTable$FisherAdjustP,decreasing=F),]
}

################## EXAMPLES ############################
Results_Example1<-TFTableFunction(data,Example1,ModuleMin=10, ModuleMax = 1400, MinSigGenes =5)

Results_Example2<-TFTableFunction(data,Example2,ModuleMin=10, ModuleMax = 1400, MinSigGenes =5)

# Target Gene Search

**Purpose:** This tool allows the user to ascertain a list of transcription factors that influence their target gene

**Instructions:** There are 2 ways to search for your target gene. You can either use the “drag and drop” option on the left side of the screen (Figure A) to select your gene, or you can use the Search tool on the right side of the column to search your gene.

Output Information | Column	Description
------------ | -------------
Column 1:Target Gene	 |  This is the target gene you have selected **To be Deleted**
Column 2: Transcription Factor | 	These are the top 15 TFs that regulate your target gene of interest
Column 3: Correlation | 	Pearson correlation coefficient between the TF and Target Gene
Column 4: P-Value	 | P value from Pearson correlation
Column 5: Q Value | 	P value (From column 4) adjusted for multiple comparisons-i.e the total number of correlations made in the TRN (146,132) 
Colum 6: R2	 | Overall out of sample R2 value **To be added as header **

# TF Search
**Purpose:** This tool allows the user to ascertain a list of transcription factors that influence their target gene

**Instructions:** There are 2 ways to search for your transcription factor. You can either use the “drag and drop” option on the left side of the screen (Figure A) to select your gene, or you can use the Search tool on the right side of the column to search your gene.

Output Information | Column	Description
------------ | -------------
Column 1: Target Gene	 | These are all of the target genes which are regulated by your transcription factor of interest
Column 2:Transcription Factor  | The TF you selected **to be deleted**
Column 3:Correlation	Pearson correlation coefficient between the TF and Target Gene
Column 4: P-Value | P value from Pearson correlation
Column 5: Q Value | P value (From column 4) adjusted for multiple comparisons-i.e the total number of correlations made in the TRN (146,132) 
Column 6: | Overall accuracy of the model on predicting expression of the given target gene, using LASSO regression

# Enrichment Tests

**Purpose:** This tool allows the user to examine what TFs are "enriched" for target genes of interest using an over-representation strategy. Statistical signifiance is calculated using one-sided fisher exact tests.

**Instructions:** Upload an .txt file that contains a list of gene names (each a separate line). There are 2 examples in this github repository. Module minimum & Max represent the minimim and maximum size of target genes in individual TF modules to consider.  Min significant genes indicates the minimum number of genes in **YOUR** dataset with in a given TF module to include in analysis.  The table of results can be downloaded.



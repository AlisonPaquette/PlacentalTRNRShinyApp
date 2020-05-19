1.  What is a Transcriptional Regulatory Network?

A transcriptional Regulatory Network (TRN) is a genome scale summary of transcription factor/target gene interactions within an organ. The placental TRN summarizes 146,132 interactions between 404 transcription factors and 9566 target genes within placental tissue.  We have summarized the results of this model into a database. For each gene, we share the top 15 transcription factors that regulate the gene.  For each transcription factor, we provide the target genes that it is predicted to regulate within our model.

2. How do transcription factors regulate gene expression?
Transcription factors are proteins that facilitate the conversion of DNA to RNA.  They are characterized by DNA binding domains that bind to specific regions of the genome, often in the promoter and enhancer regions of genes.  The binding of the transcription factor to this target region can either stimulate or repress gene expression.  

3. What are the requirements for a transcription factor/target gene relationship to occur?

For our model, we will report a transcription factor regulates a target gene if the following criteria are met:

1. The gene encodes transcription factor as identified by the Human Transcription factor database(Lambert et al.).

2. The transcription factor has a binding site within the promoter region (+/- 5000 KB) or an enhancer region (defined by Genehancer (Fishilevich et al.)). Transcription factor binding sites were identified using established databases including JASPAR (Khan et al.), HOCOMOCO (Kulakovskiy et al.),and Swissregulon (Pachkov et al.).

3. The binding site sits within a region of open chromatin, quantified using placental DNAse hypersensitivity data.

4.  There is a strong (|r|>0.25), significant  (FDR adjusted Q <0.05) association between the transcription factor and the target gene. We  also only include the TOP 15 TFs for each gene in our network.

5. We were able to predict the accuracy of the target gene in our holdout dataset with an accuracy higher than 0.25 using lasso regression. If the accuracy was less than 0.25, we will not report this in our database. We include this list of excluded genes here. 

This is summarized in the figure below:

It is important to note that since we only report on the top 15 TFs that regulate every gene.  Without this restriction, we would have a much larger network, and it would be challenging to interpret results and perform enrichment analysis. If you do not see a TF/target gene interaction that you would expect to see, please reach out and we can try to figure out what criteria was missing.

4. Why are we building this model in the placenta? 

The placenta is a unique and ephemeral organ that is essential for fetal development and long term health. Despite its significance, the placenta remains one of the most understudied organs in the human body. This TRN is designed as a tool to contribute to our understanding of the human placenta, and aid other placental biology researchers.

5. What are some assumptions this model makes?

We are using TF expression as a metric for TF activity. This is an imprecise relationship that makes many assumptions, which is why we have made efforts to validate our model experimentally, and we provide the accuracy of our model in a test dataset. Ideally, we would quantify protein activity and gene expression. This model is constructed of RNA sequencing data from bulk placental tissue (from the fetal side). The specific cell types present within this tissue likely have different patterns of gene expression, which is obscured in our final model. This information would be better represented using single cell RNA sequencing data, which was beyond the scope of this analysis.

Fishilevich, Simon, et al. “GeneHancer: Genome-Wide Integration of Enhancers and Target Genes in GeneCards.” Database : The Journal of Biological Databases and Curation, vol. 2017, Apr. 2017, p. bax028, doi:10.1093/database/bax028. PubMed, 28605766.
Khan, Aziz, et al. “JASPAR 2018: Update of the Open-Access Database of Transcription Factor Binding Profiles and Its Web Framework.” Nucleic Acids Research, vol. 46, no. D1, Jan. 2018, pp. D260–66, doi:10.1093/nar/gkx1126.
Kulakovskiy, Ivan V., et al. “HOCOMOCO: Towards a Complete Collection of Transcription Factor Binding Models for Human and Mouse via Large-Scale ChIP-Seq Analysis.” Nucleic Acids Research, vol. 46, no. D1, Jan. 2018, pp. D252–59, doi:10.1093/nar/gkx1106.
Lambert, Samuel A., et al. “The Human Transcription Factors.” Cell, vol. 172, no. 4, Feb. 2018, pp. 650–65, doi:10.1016/j.cell.2018.01.029.
Pachkov, Mikhail, et al. “SwissRegulon: A Database of Genome-Wide Annotations of Regulatory Sites.” Nucleic Acids Research, vol. 35, no. suppl_1, Jan. 2007, pp. D127–31, doi:10.1093/nar/gkl857.


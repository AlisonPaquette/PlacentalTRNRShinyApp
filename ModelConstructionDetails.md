The methodology used to summarize the construction of network is briefly summarized below. For a full description, please see our manuscript **Link to Publication Eventually**

**RNA Sequencing Data**
To construct the TRN, we integrated transcriptomic and chromatin accessibility data from placental tissue generated from two different cohorts. For both cohorts, we excluded samples with maternal age <18, or any pregnancy complications including: intrauterine growth restriction, chromosomal abnormalities, preeclampsia, gestational diabetes, chorioamnionitis, antepartum hemorrhage.These cohorts have an even distribution of male and female samples, and represent a relatively racially diverse cohort. More information about the samples included is summarized within the manuscript. RNA was extracted from bulk placental tissue and sequenced **NEED MORE DETAILS HERE*. Transcript abundances were estimated using the quantification program Kallisto (Bray et al.), and condensed to Ensembl Gene IDs using TXImport(Soneson et al.). The 2 RNA sequencing datasets were merged together and genes were filtered using default parameters within EdgeR, and normalized using trimmed mean of M (TMM). Batch effects from 2 datasets were mitigated using an the Combat algorithm from the R package “SVA”(Leek and Storey). For TRN Construction, the data was split into a holdout dataset (20% of samples-N=93), and 20% of the remaining data was used for the testing dataset (N=75), with 80% used for the construction of the initial TRN (N=307). In the final model, all data was used (N=476 samples).

**DNAse Hypersensitivity Data**
12 placental samples were derived from non-pathological, term pregnancies (28 weeks 2 days-39 weeks 4 days), from matched male and female samples, from women who delivered via c-section at the OHSU Center for Women’s health.   DNAse hypersensitivity data was processed from the samples collected at OHSU by the Altius Institute using established protocols developed as part of the ENCODE project(Consortium). Samples were processed using the DHS-pseudonano assay & nuclei were sterile filtered (0.25-6.4 milion nuclei/sample),  with minimal cellular debris, and treated with 3 doses of DNAse (40, 60 and 80 units) followed by a stop buffer including RNAse A, followed by treatment with proteinase K. Peak regions of DNase-seq data were identified using F-seq (Boyle et al.), a density estimator for high-throughput sequence tag, using a threshold parameter of 2.5, which was selected based on previously reported performance metrics(Koohy et al.). These peak regions data and DNase-seq data were both used to detect transcription factor footprints using HINT (Gusmao et al.), a method based on hidden Markov models. 

**Transcription Factor Motifs & Single Gene Model Construction**
Transcription factor binding sites were identified using established databases including JASPAR(Khan et al.), HOCOMOCO(Kulakovskiy et al.),and Swissregulon(Pachkov et al.). Transcription factors were defined as those defined by the HumanTFDB which had motifs from these the TF databases (667 TFs)(Lambert et al.). The motifs were aggregated into position weight matrixes within the R package “MotifDB”(Paul Shannon) . We identified TF binding sites upstream and downstream of every Ensembl Gene ID using FIMO.(Grant et al.) We assigned motifs to their TFs as well as those in the same DNA-binding domain family using the TFClass database. In our analysis, we did not consider the subset of transcription factors with no known motifs. We included both promoter and enhancer regions in our model.  The promoter region was defined as +/- 5KB from the TSS which been shown to maximize target gene prediction in transcriptional regulatory networks constructed with footprinting data(Plaisier et al.). The enhancer regions were defined using genehancer(Fishilevich et al.).  We included all enhancer regions defined by genehancer as “elite”; indicating that they had more than 2 evidence sources, and those defined as “placental” specific by genehancer. 

**TRN Construction & Parameterization**
A “putative edge” was identified between a TF and a target gene if a motif for that transcription factor was present in a region of open chromatin (i.e footprint) in the genes promoter or enhancer . We generated a co-expression matrix for each “putative edge within our training dataset.  We ranked each target gene based on the absolute value of the Pearson correlation coefficient. We pruned our model by first including only TFs with > median absolute value of the overall Pearson correlation coefficient, then including only the top 15 genes based on absolute Pearson correlation coefficient. To evaluate the accuracy of our TRN and select model parameters for our full model, we used LASSO regression to evaluate how the expression of the TFs in our model predicted gene expression of each target gene in our testing dataset. The R2  value was calculated as the squared estimate of the correlation between the predicted vs. actual expression values. Analysis was performed using the “glmnet” packages. We also evaluated “null” TRNs within our training dataset to evaluate the validity of our model. After initial model parameterization in our training and testing dataset, we moved on to combine these 2 datasets, and then test the model in our final holdout dataset. We did not include target genes with an out of sample R2 accuracy <0.25. 

**References**
Boyle, Alan P., et al. “F-Seq: A Feature Density Estimator for High-Throughput Sequence Tags.” Bioinformatics, vol. 24, no. 21, Nov. 2008, pp. 2537–38, doi:10.1093/bioinformatics/btn480.

Bray, Nicolas L., et al. “Near-Optimal Probabilistic RNA-Seq Quantification.” Nat Biotech, vol. 34, no. 5, May 2016, pp. 525–27.

Consortium, The ENCODE Project. “An Integrated Encyclopedia of DNA Elements in the Human Genome.” Nature, vol. 489, no. 7414, Sept. 2012, pp. 57–74. www.nature.com, doi:10.1038/nature11247.

Fishilevich, Simon, et al. “GeneHancer: Genome-Wide Integration of Enhancers and Target Genes in GeneCards.” Database : The Journal of Biological Databases and Curation, vol. 2017, Apr. 2017, p. bax028, doi:10.1093/database/bax028. PubMed, 28605766.
Grant, Charles E., et al. “FIMO: Scanning for Occurrences of a given Motif.” Bioinformatics (Oxford, England), vol. 27, no. 7, Apr. 2011, pp. 1017–18, doi:10.1093/bioinformatics/btr064. PubMed, 21330290.

Gusmao, Eduardo G., et al. “Detection of Active Transcription Factor Binding Sites with the Combination of DNase Hypersensitivity and Histone Modifications.” Bioinformatics, vol. 30, no. 22, Nov. 2014, pp. 3143–51, doi:10.1093/bioinformatics/btu519.

Khan, Aziz, et al. “JASPAR 2018: Update of the Open-Access Database of Transcription Factor Binding Profiles and Its Web Framework.” Nucleic Acids Research, vol. 46, no. D1, Jan. 2018, pp. D260–66, doi:10.1093/nar/gkx1126.
Koohy, Hashem, et al. “A Comparison of Peak Callers Used for DNase-Seq Data.” PLOS ONE, vol. 9, no. 5, May 2014, p. e96303, doi:10.1371/journal.pone.0096303.

Kulakovskiy, Ivan V., et al. “HOCOMOCO: Towards a Complete Collection of Transcription Factor Binding Models for Human and Mouse via Large-Scale ChIP-Seq Analysis.” Nucleic Acids Research, vol. 46, no. D1, Jan. 2018, pp. D252–59, doi:10.1093/nar/gkx1106.

Lambert, Samuel A., et al. “The Human Transcription Factors.” Cell, vol. 172, no. 4, Feb. 2018, pp. 650–65, doi:10.1016/j.cell.2018.01.029.

Leek, Jeffrey T., and John D. Storey. “Capturing Heterogeneity in Gene Expression Studies by Surrogate Variable Analysis.” PLOS Genetics, vol. 3, no. 9, Sept. 2007, p. e161, doi:10.1371/journal.pgen.0030161.

Pachkov, Mikhail, et al. “SwissRegulon: A Database of Genome-Wide Annotations of Regulatory Sites.” Nucleic Acids Research, vol. 35, no. suppl_1, Jan. 2007, pp. D127–31, doi:10.1093/nar/gkl857.

Paul Shannon. MotifDb: An Annotated Collection of Protein-DNA Binding Sequence Motifs. R version 1.16.1, 2017.

Plaisier, Christopher L., et al. “Causal Mechanistic Regulatory Network for Glioblastoma Deciphered Using Systems Genetics Network Analysis.” Cell Systems, vol. 3, no. 2, Aug. 2016, pp. 172–86, doi:10.1016/j.cels.2016.06.006.

Soneson, C., et al. “Differential Analyses for RNA-Seq: Transcript-Level Estimates Improve Gene-Level Inferences [Version 1; Referees: 2 Approved].” F1000Research, vol. 4, no. 1521, 2015, doi:10.12688/f1000research.7563.1.


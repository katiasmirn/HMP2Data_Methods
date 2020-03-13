rm(list=ls())
library(data.table)
library(tidyr)
library(dplyr)
library(stringr)
path <- "Documents/moms/"
path2 <- "Documents/MOMS-PI/71694/PhenoGenotypeFiles/RootStudyConsentSet_phs001523.MOMS_PI.v1.p1.c1.DS-PREG-COM-IRB-PUB-MDS/PhenotypeFiles/"
MOMSPI_stirrups<- as.data.frame(fread("Documents/stirrups.profile/hmqcp/MOMS_PI_allstirrups.txt"),sep="\t",header=FALSE,quote="")
colnames(MOMSPI_stirrups)<- c("Sample_Name","Taxon","Threshold_Status","No_Reads","Percent_Abundance","Average_Identity")
#For normalizing to only to those that had a hit (AT only)
#This might be the default, but we might also want to incorporate an option for all reads, including those without a hit
MOMSPI_stirrups_ATonly<-subset(MOMSPI_stirrups,MOMSPI_stirrups$`Threshold_Status`=="AT")
MOMSPI_stirrups_ATonly_forwide<-MOMSPI_stirrups_ATonly
MOMSPI_stirrups_ATonly_forwide$Threshold_Status<-NULL
MOMSPI_stirrups_ATonly_forwide$Percent_Abundance<-NULL
MOMSPI_stirrups_ATonly_forwide$Average_Identity<-NULL
momspi <- as.data.frame(spread(MOMSPI_stirrups_ATonly_forwide,key = Taxon, value = No_Reads))
rownames(momspi) <- momspi[,1]
momspi[,1] <- NULL
#a <- substring(rownames(momspi),1,8)
#amt <- length(unique(a))
load("Documents/HMP2Data/data/momspi16S_mtx.rda")
load("Documents/HMP2Data/data/momspi16S_samp.rda")
load("Documents/HMP2Data/data/momspi16S_tax.rda")
oldmoms <- colnames(momspi16S_mtx)
newmoms <- rownames(momspi)
outernew <- momspi[(!newmoms %in% oldmoms),]
outerold <- momspi16S_mtx[,(!oldmoms %in% newmoms)]

vSamps <- momspi16S_samp[which(momspi16S_samp[,'sample_body_site'] == 'vagina'),]
vSamps
vrows <- rownames(vSamps)
outersamps <- vSamps[(!newmoms %in% vrows),]


#outernew and outersamps are the taxa which are located in the new (custom) momspi file, not in the old (greengenes) momspi (15 samples)
#outersamps are the taxa which are located in the old momspi file, not in the new momspi (2 samples)
#The tax file has the corresponding taxa id to their actual taxa names, but only goes to the species level

# The data16S file is similarly formatted to the momspi file, so use that method to append the genus level to the 
# tax file and use the id's from the tax as a key to go back to the mtx file to update these values and then 
# eventually to the sample file (I don't think I need to mess with the sample id's at all, just the mtx and tax tables)

#rownames(outerold)       # taxa id's
#momspi[newmoms %in% vrows,]
#colnames(momspi)         # taxa names
#rownames(momspi16S_mtx)  # taxa id's

#match <- rownames(momspi[newmoms %in% oldmoms,])


#Starting Quy's Taxa Filter Script:
#momspi2 <- data.frame(t(momspi[-1]))
#colnames(momspi2) <- momspi[, 1]
#momspi[is.na(momspi)] <- 0

#Create taxa table for momspi table where genus species is split by the first underscore _
# Add column for full name to double check this

# Create separate taxa table for custom database 
# Create separate mtx for custom database
fName <- colnames(momspi)
both <- str_split_fixed(fName, "_", n = 2)
Genus <- both[,1]
Species <- both[,2]

#rows_ones <- paste("cdb_00000", 1:9, sep = "")
#rows_tens <- paste("cdb_0000", 10:99, sep = "")
#rows_hund <- paste("cdb_000", 100:360, sep = "")
#rows <- c(rows_ones, rows_tens, rows_hund)
Kingdom <- rep(NA, 360)
Phylum <- rep(NA ,360)
Class <- rep(NA, 360)
Order <- rep(NA, 360)
Family <- rep(NA, 360)
moms_taxa <- data.frame(Kingdom, Phylum, Class, Order, Family, Genus, Species, row.names = fName) #full taxa with genus, species, and full taxa name
#Combines with larger taxa table
#momsTaxa <- data.frame(momspi16S_tax)
#comb <- rbind(momsTaxa, moms_taxa[,1:7])

meta_sub <- momspi16S_samp[rownames(momspi16S_samp) %in% rownames(momspi),] 
#15 samples missing, fill in sample rows with NA's for these missing ones
missing <- which(!rownames(momspi) %in% rownames(meta_sub))
names <- c(rownames(momspi[missing,]))
meta_sub[nrow(meta_sub) + length(missing),] <- NA
#rownames(meta_sub[2041:2055,]) <- names
firstNames <- rownames(meta_sub[1:2040,])
allNames <- c(firstNames, names)
rownames(meta_sub) <- allNames
#meta_sub should have all samples in the dataset


#Create phyloseq object:
OTU = otu_table(t(momspi), taxa_are_rows = TRUE)
taxa <- as.matrix(moms_taxa)
TAX = tax_table(taxa)
samples = sample_data(meta_sub)

rownames(taxa) <- rownames(t(momspi))
carbom <- phyloseq(OTU, TAX, samples)
##################################################

#Makes first row into column names
header.true <- function(df) {
  names(df) <- as.character(unlist(df[1,]))
  df[-1,]
}

blah <- read.table(paste(path2, "phs001523.v1.pht008454.v1.p1.MOMS_PI_SRA.MULTI.txt", sep=""), fill = TRUE, header = FALSE, sep = "", dec = ".")
blah <- header.true(blah)
names(blah)

#See which from custom database are in the biostat server text file sample id's
check <- momspi[newmoms %in% blah$SAMPLE_ID,] #2055 obs x 360 variables (so all samples in custom are captured)
samps <- blah[blah$SAMPLE_ID %in% newmoms,]
filelist = list.files(path = path2, pattern = ".*.txt$")


try <- read.table(paste(path2, filelist[2], sep=""), fill = TRUE, header = FALSE, sep = "", dec = ".")
try <- header.true(try)
hope <- merge(samps, try)

one <- read.table(paste(path2, filelist[1], sep=""), fill = TRUE, header = FALSE, sep = "\t", dec = ".")
one <- header.true(one)
hope <- merge(hope,one)

three <- read.table(paste(path2, filelist[3], sep=""), fill = TRUE, header = FALSE, sep = "\t", dec = ".")
three <- header.true(three)
visits <- three$visit_ID

which(three$visit_ID %in% hope$SAMPLE_ID)
hope <- merge(hope, three)


for (file in filelist) {
  exa <- read.table(paste(path2, file, sep=""), fill = TRUE, header = FALSE, sep = "", dec = ".")
  exa <- header.true(exa)
  samps <- merge(samps,exa)
  
}
exa <- read.table(paste(path2, filelist[1], sep=""), header = FALSE, sep = "", dec = ".")
exa <- header.true(exa)

check <- momspi[newmoms %in% exa$SUBJECT_ID,]


newdf <- momspi[match,]
colnames(newdf) <- rows
newdf2 <- data.frame(t(newdf[,]))
newdf2[is.na(newdf2)] <- 0
momspi16SData <- data.frame(momspi16S_mtx)
comb_mtx <- bind_rows(momspi16S_mtx, newdf2)
firstrows <- rownames(momspi16S_mtx)
secondrows <- rownames(newdf2)
allrows <- c(firstrows, secondrows)
#rownames(comb_mtx[1:7665,]) <- firstrows
#rownames(comb_mtx[7666:8025,]) <- rownames(newdf2)
rownames(comb_mtx) <- allrows

#write.csv(comb_mtx, paste(path, "customdb.csv", sep=""))

#Try to line momspi16S_samp with the biostat server sample names, so that we can then combine these into 
#a larger metadata file for the samples
#9203 sample id's


#use here for file path
#subset custom database metadata from full metadata
#combine into one phyloseq object with: taxa table, otu table, and sample table
#make rds file for metadata, which merges to phyloseq object
# for phyloseq, use limited metadata, with sample id and link
#     Don't put all the info onto the phyloseq directly yet, do it later step, keep it separated (think of person who doesn't have access to metadata)
# Create one script for structuring custom files, use momspi16S_samp for the current metadata
# Create another script for adding metadata files
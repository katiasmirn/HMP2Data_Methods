# HMP2Data_Methods

## Downloading the data

All publicly available stirrups data were downloaded from the Human Microbiome Project Data Portal (https://portal.hmpdacc.org/) on 01/03/2020. Specifically, "Project: Integrative Human Microbiome Project" was selected, followed by the selection of the study "MOMS-PI" (Multi-Omics Microbiome Study - Pregnancy Initiative). Subsequent filters were applied to obtain "stirrups profile" data (16S data with VCU vaginal custom data base community assignment) in txt format. 

The data were downloaded using Aspera client `Aspera cli` (availavle as a shell script  ibm-aspera-cli-*-release.sh from https://downloads.asperasoft.com/en/downloads/62). See instructions on how to execute a shell script (https://www.cyberciti.biz/faq/run-execute-sh-shell-script/, https://askubuntu.com/questions/38661/how-do-i-run-sh-scripts or similar) to install `Aspera cli`.  Once Aspera client is properly installed, an executable file `ascp` should be visible in your `/Users/ekaterinasmirnova/Applications/Aspera\ CLI/bin/` folder.  

The stirrups data were downloaded using shell script `ascp-commands_stirrups_MOMS-PI.sh` available in the `Scripts/` folder. 

### Stirrups data download workflow

* Go to https://portal.hmpdacc.org, select "Data", Samples/Studies select MOMS-PI, Files/Format select "tbl", Files/Matrix Type select "16s_community"
* Format: Study Name IS MOMS-PI AND File Format IS tbl AND File Matrix Type IS 16s_community 
* Download Stirrups data: ./hmp_client/bin/manifest2ascp.py --manifest=data.MOMS-PI/hmp_cart_2ae82fd042.tsv --user=username --password=password --ascp_path=/path/to/ascp/bin/ascp --ascp_options="-l 200M" > ascp-commands_biom_16S_MOMS-PI.sh

## Processing downloaded data




## Contact information


If you have questions, comments, or suggestions you feel free to contact Karun Rajesh (rajeshk@mymail.vcu.edu) Ekaterina Smirnova  (ekaterina.smirnova@vcuhealth.org).



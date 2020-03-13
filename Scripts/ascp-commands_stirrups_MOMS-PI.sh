#!/bin/bash
#specify the pack to aspera
export PATH=/Users/esmirnova/Applications/Aspera\ CLI/bin:$PATH

export ASCP=/Users/ekaterinasmirnova/Applications/Aspera\ CLI/bin/ascp
export ASPERA_USER=esmirnova
export ASPERA_SCP_PASS=Otp100l!


#one file download, can use manifest to specify files
#downloads data into home directory /ptb/genome/microbiome/16s/analysis/hmqcp/stirrups.profile/

/Users/ekaterinasmirnova/Applications/Aspera\ CLI/bin/ascp -d  -l 200M esmirnova@aspera.ihmpdcc.org:ptb/genome/microbiome/16s/analysis/hmqcp/EP492474_K10_MV1D.stirrups.profile.txt ~/ptb/genome/microbiome/16s/analysis/hmqcp/stirrups.profile/

# download all files matching patterns, but downloads .biom files along with stirrups
# downloads data into directory with file location, then 

ascp -d  -l 200M  -N '*.stirrups.profile.txt'   esmirnova@aspera.ihmpdcc.org:ptb/genome/microbiome/16s/analysis/hmqcp/ ~/ptb/genome/microbiome/16s/analysis/hmqcp/stirrups.profile/

# remove biom files
find . -maxdepth 1 -name '*.biom' -delete


#!/bin/bash - 
#===============================================================================
#
#          FILE: install.sh
# 
#         USAGE: ./install.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Peter Belmann (), pbelmann@cebitec.uni-bielefeld.de
#  ORGANIZATION: Computational Metagenomics
#       CREATED: 04/29/17 21:43:29
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

apt update && apt install -y software-properties-common libssl-dev wget apt-transport-https

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && 
   add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && 
   apt update && 
   apt install -y wget r-base libcurl4-openssl-dev

wget https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb && 
    dpkg -i pandoc-1.19.2.1-1-amd64.deb && rm pandoc-1.19.2.1-1-amd64.deb

R -e 'install.packages("packrat" , repos="http://cran.us.r-project.org"); packrat::restore()'

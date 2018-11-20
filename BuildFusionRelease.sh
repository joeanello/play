#!/bin/bash

#===============================================================================
# BuildFusionRT.sh - Semi-automated script to build  Fusion Server Run-Time
#===============================================================================
#
# Modification History:
#   20-Nov-2018 <jwa> - Created Script
#
#===============================================================================

#-<jwa>-----------------------------------------------
# Let's include a little color into the output using
# VT100 (TTY) Substitutions
ESC=
COL60=$ESC[60G

# Attributes    ;    Foregrounds     ;    Backgrounds
atRST=$ESC[0m   ;   fgBLK=$ESC[30m   ;   bgBLK=$ESC[40m
atBRT=$ESC[1m   ;   fgRED=$ESC[31m   ;   bgRED=$ESC[41m
atDIM=$ESC[2m   ;   fgGRN=$ESC[32m   ;   bgGRN=$ESC[42m
atUN1=$ESC[3m   ;   fgYEL=$ESC[33m   ;   bgYEL=$ESC[43m
atUND=$ESC[4m   ;   fgBLU=$ESC[34m   ;   bgBLU=$ESC[44m
atBLK=$ESC[5m   ;   fgMAG=$ESC[35m   ;   bgMAG=$ESC[45m
atUN2=$ESC[6m   ;   fgCYN=$ESC[36m   ;   bgCYN=$ESC[46m
atREV=$ESC[7m   ;   fgWHT=$ESC[37m   ;   bgWHT=$ESC[47m
atHID=$ESC[8m   ;   fgNEU=$ESC[39m   ;   bgNEU=$ESC[49m

#==============================================================================
# Local Function Definitions
#==============================================================================

#---[ gap - adds a gap in the output ]-----------------
#
gap() {
   echo 
   echo
   echo
} #---[ end gap() ]------------------------ 


#---[ decho() - Outputs text when the Debug Flag is set ]-----------------
#
decho() {
    if [[ ${BLD_DEBUG} == 1 ]] ; then
        echo "D: $*"
    fi

} #---[ end decho() ]------------------------


#---[ vecho() - Outputs text when the Verbose Flag is set ]-----------------
#
vecho() {
    if [[ ${VERBOSE} == 1 ]] ; then
        echo "V: $*"
    fi

} #---[ end vecho() ]------------------------



#--------------------------------------------------------------------
# Constants, Debug and Verbosity Flags
#
BUILD_SEED=3456
BLD_DEBUG=1
VERBOSE=1
echo " "
decho "<<<Debug is Active>>>"
vecho "<<<Verbose is Active>>>"


# -------------------------------------------------------------------
# Set the target path
#
MAIN_DIR=`pwd`
vecho "Working in ${MAIN_DIR}"



#===============================================================================
# Mainline begins here...
#

# 1) Start by making sure we have and update the file that tracks the build information
# 1a) Find and parse the version.txt file to get the Version and Build Version
#
if ! [ -a ${MAIN_DIR}/version.txt ] ; then
    #
	# File does not exist - bail
    echo "${fgRED}${atBRT} ERROR 1001: Version information file not found${fgNEU}${atRST}"
	echo "Aborting"
	exit 1001
fi
	
# 1b) File exists, check first two fields to make sure the format is correct
#
STR1=`cut -d' ' -f1 ${MAIN_DIR}/version.txt`
STR2=`cut -d' ' -f2 ${MAIN_DIR}/version.txt`
decho "Strings are: ${STR1} and ${STR2}"

if ! [[ (${STR1} == "FusionOS") && (${STR2} == "Version") ]] ; then
	echo "${fgRED}${atBRT} ERROR 1002: Version information file format is incorrect${fgNEU}${atRST}"
	exit 1002
fi

# 1c) Get the Version, Release Level, and process Build Number
#
STR3=`cut -d' ' -f3 ${MAIN_DIR}/version.txt`
STR4=`cut -d' ' -f4 ${MAIN_DIR}/version.txt`
STR5=`cut -d' ' -f5 ${MAIN_DIR}/version.txt`
decho "Strings are: ${STR3} ${STR4} and >${STR5}<"

if [[ ${STR5} == "" ]] ; then
	let "STR5 = $BUILD_SEED"
else
	let "( STR5 = STR5 + 1 )"
fi

decho "Strings are now: ${STR3} ${STR4} and >${STR5}<"
echo "${STR1} ${STR2} ${STR3} ${STR4} ${STR5}" > version.txt

# 1d) Update the local repo with the version information and push it to the 
#		upstream master.
#
decho "Committing changes to local repository..."
git commit -a -m "Set Revision Information to ${STR1} ${STR2} ${STR3} ${STR4} at Build ${STR5}"
decho
decho "Pushing changes to upstream Repository"
git push  





exit 65535

AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY


# highwater   highwater   highwater   highwater   highwater   highwater
# highwater   highwater   highwater   highwater   highwater   highwater
# highwater   highwater   highwater   highwater   highwater   highwater




GETTING THE SOURCE CODE ONTO THE BUILD SYSTEM:
Log into the build system as the superuser and create a directory to hold all of the work

# Make a new directory called staging to perform all work within 
mkdir staging 
cd staging  

# Clone the dev and release repositories 
git clone http://github.com/Modern-Robotics/Fusion-dev.git 
git clone http://github.com/Modern-Robotics/Fusion.git 


# Reset to the commit id of the proposed release, skip this step if the current
# commit is the one being released. 
git reset --hard $commitID


# Create a new branch named release and verify with no commits
git checkout --orphan release 
git branch  # 2 are shown: the release candidate branch and the master
git log     # fatal: bad default revision 'HEAD'


BUILDING THE RUN-TIME VERSION FOR RELEASE:

#================================================================================
# Edit the README.md file with end-user approved release notes for the build.
# Be sure to include the version information without the Release Candidate 
# notation.
# 
nano README.md 


#--------------------------------------------------------------------------------
# Compile all necessary files and remove all source files at this time that are 
# not intended to be in the final release

# 1) Modify .gitignore file to include Build/ and node_modules/
cd ./staging/Fusion-dev 
nano .gitignore 
    # ((( Remove Build/ and node_modules/ from the file )))


# 2a) Build the Documentation
# productionBuild automatically places doc files into FusionServer/Src directories 
cd ./staging/Fusion-dev/docsrc 
./productionBuild.sh    

# 2b) Delete the Document Source folder and the build script
cd ./staging/Fusion-dev
rm -r docsrc 


# 3a) Build the Fusion Server
# The automated serverBuild.sh script runs the entire build process
cd ./staging/Fusion-dev/FusionServer
./serverBuild.sh

# 3b) Delete the Source folder and the build script
rm -r Src 
rm –r serverBuild.sh    


# 4a) Build the Diagnostic Utiltiy
# The automated compile.sh script runs the entire process
cd ./staging/Fusion-dev/diagnostics
./compile.sh

# 4b) Retain the following files and folders
    diagnosticGui.py
    psutil/
    res/
    runRemi.sh 
    src.so


# 5a) Build the data Logging Utility
# The automated compile.sh script runs the entire process
cd ./staging/Fusion-dev/logging
./compile.sh

# 5b) Retain the following files and folders
    dataLogger.py
    res/
    runRemi.sh 
    src.so


# 6) Build procedure for Libraries 
# The automated compile.sh script runs the entire process except for
#   a few housekeeping issues...

# 6a) Clean out any old compiled libs 
cd ./staging/Fusion-dev/lib 
rm -r Fusion*

# 6b) Verify that the Library Version Number is correct:
cd ./staging/Fusion-dev/lib/python/src 
nano setup.py 
    # Change the version if necessary else note for future reference. 

# 6c) Run the build process
cd ./staging/Fusion-dev/lib/python
./compile.sh
    # The final production .tar.gz is placed in the parent directory 
    # (ie:./staging/Fusion-dev/lib)

# 6d) Move up to the parent directory and get rid of the source files
cd ..
# Retain the following files and folders
    Fusion-x.x.x.tar.gz
    *.deb 
    *.tar.gz 
    noVNC/ 
    


# 7) Verify that the update.sh script is correct and includes any new libraries,
#    changes, files, etc necessary to properly update an older version of code
#    to the current version
cd ./staging/Fusion-dev
nano update.sh 

#---------------------------------------------------------------------------------
# This file should be updated ANYTIME A NEW FILE OR LIB IS ADDED, MOVED, DELETED 
# that pertains to the overall operation of the production environment so that 
# this step in the end is more of a verify than a what the hell did I do to get 
# that to work step. 

# This is crucial as this is the update scheme that is used by an older Fusion
# to bring it up to date. 
#------------------------------------------------------------------------------



# 8) Final cleanup of the main Fusion-dev directory 
cd ./staging/Fusion-dev 

# Retain the following files in the main directory 
    diagnostics/
    etc/
    FusionServer/
    .git*   
    lib/
    logging/
    README.md       # This file should have been updated earlier with notes
    update.sh 
    
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV


#==============================================================================
# Mainline begins here...

echo 
echo "$atBRT$fgBLU     ( ( ( ( ( FusionServer Build Processor ) ) ) ) )$atRST$fgNEU"
echo ""

# Install the autoconf package since several library builds require it
echo "$fgRED...Installing additional packages...$fgNEU"
apt-get install autoconf
echo

# Remove build directory if exists
echo "$fgRED...Removing existing Build directory...$fgNEU"
sudo rm -r Build
echo

# change to source directory
echo "$fgRED...Entering Source Directory...$fgNEU"
cd Src
if [[ $? != 0 ]]; then exit 1; fi

# run a full npm install
echo "$fgRED=============================================================================="
echo "   Beginning full nmp install  $fgNEU"
sudo npm install
if [[ $? != 0 ]]; then exit 2; fi
echo "$fgRED   Completed fill npm install"
echo "==============================================================================$fgNEU"
gap

# globally install gulp 
echo "$fgRED=============================================================================="
echo "   Beginning global install of gulp  $fgNEU"
sudo npm install --global gulp
if [[ $? != 0 ]]; then exit 3; fi
echo "$fgRED   Completed global install of gulp"
echo "==============================================================================$fgNEU"
gap

# link the gulp file
echo "$fgRED=============================================================================="
echo "   Beginning linking the gulp file  $fgNEU"
sudo npm link gulp
if [[ $? != 0 ]]; then exit 4; fi
echo "$fgRED   Completed linking the gulp file"
echo "==============================================================================$fgNEU"
gap

# run gulp to obfuscate code
echo "$fgRED=============================================================================="
echo "   Beginning code obfuscation  $fgNEU"
sudo gulp 
if [[ $? != 0 ]]; then exit 5; fi
echo "$fgRED   Completed code obfuscation"
echo "==============================================================================$fgNEU"
gap

# change to build directory 
echo "$fgRED...Moving to the Build directory...$fgNEU"
cd ../Build
if [[ $? != 0 ]]; then exit 6; fi
echo

# run production level install 
echo "$fgRED=============================================================================="
echo "   Beginning production level installation  $fgNEU"
sudo npm install --production 
if [[ $? != 0 ]]; then exit 7; fi
echo "$fgRED   Completed production level installation"
echo "==============================================================================$fgNEU"
gap

# successful completion of Fusion Server build process
echo "$atBRT$fgGRN=============================================================================="
echo  "   Fusion Server Built Successfully!       <...and the people say, AMEN!...>"
echo "==============================================================================$atRST$fgNEU"
gap










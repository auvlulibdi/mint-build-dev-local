#!/bin/zsh
#
# this script generates LTU ResearchMaster {Parties_People|Activities_Other_Projects} reports
# 
# Parties_People            report = ${fascinator.home}/data/Parties_People_LTU.csv
# Activities_Other_Projects report = ${fascinator.home}/data/Activities_LTU.csv
#               ${fascinator.home} =  /opt/mint
# 
# di_runreport.sh <Parties_People|Activities_Other_Projects>
#

# functions
  usage() {
  	echo "Usage: di_runreport.zsh {Parties_People_LTU|Activities_LTU}"
  	exit 1
  }

# setup environment

  # TF env
    export PROG_DIR=`cd ${progName}; pwd`

    export PROG_DIR=`cd \`dirname $0\`; pwd`
    . $PROG_DIR/tf_env.sh &> /dev/null

  # harvest directory
    EXPORT_DIR=${TF_HOME}/data

  # report directory
    RPT_PROG_DIR="${TF_HOME}/jasper"
    RPT_PROG="RunReport"

  # log
    progName=`basename $0`
    curDate=`/bin/date +%Y%m%d%H%M`
    LOG="/tmp/${progName}_${curDate}.log"
    touch $LOG

  # java
    JAVA='/usr/bin/java'

# display program header
  # echo "DigitalInfrastructure - ResearchMaster Report - Mint - $REDBOX_VERSION"

# check number of arguments
  if [ $# != 1 ]; then
    usage
  fi

# check arguments
  RPT_NAME=$1
  if [[ ${RPT_NAME} == 'Parties_People_LTU' ]]; then
    RPT_NAME_OUT='Parties_People'
    EXPORT_FILE_BASE='Parties_People_LTU'
  elif [[ ${RPT_NAME} == 'Activities_LTU' ]]; then
    RPT_NAME_OUT='Activities'
    EXPORT_FILE_BASE='Activities_LTU'
  else
    usage
    exit 1
  fi

# cd to report program dir
  cd ${RPT_PROG_DIR}
  if [[ $? != 0 ]]; then
    echo " ! Failed to cd to report directory (${RPT_PROG_DIR})"
    exit 1
  fi

# run report 
  # java -Djava.awt.headless=true   -cp lib/*: RunReport Activities
  # 20130104 : cja : -D java.awt.headless=true added to avert 'X11' error. 
  # See http://stackoverflow.com/questions/10165761/java-cant-connect-to-x11-window-server-using-localhost10-0-as-the-value-of-t for reference
  $JAVA -Djava.awt.headless=true -cp 'lib/*:' ${RPT_PROG} ${RPT_NAME_OUT} &> $LOG

  if [[ $? != 0 ]]; then
    echo " ! Failed to run ${RPT_PROG_DIR}/${RPT_PROG}"
    echo " ! See $LOG for details"
    exit 1
  else
    # sed -i -e "1d" strips first line. Required because field-list from RunReport.java for Parties_People is bjorked => replace with $strHeader
    strHeader="CPERSON_PK,SIDNUM,SSTUDID,SSURNAME,SGIVENNAME,SMIDNAME,CTYPE,SPERTITLE,LCURRENT,SGENDER,SEMAIL,VI_FOR,NPERCENT"
    prefixCmd="sed s/^/AU-VLU/g"
    if [[ $RPT_NAME_OUT == 'Activities' ]]; then
      strHeader="ID,Submit Year,Start Year,Title,Description,Institution,Investigators,Discipline"
      # prefixCmd='cat'  # We want 'AU-VLU' prefix for activities too!
    fi
    cat "${RPT_NAME_OUT}.csv" | sed -e "1d" | `echo ${prefixCmd}` | prepend -s ${strHeader} | \
    awk -f ${RPT_NAME_OUT}1of2.awk | awk -f ${RPT_NAME_OUT}2of2.awk | \
    sed "s/  */ /g" | sed "s/ ,/,/g" \
    > "${EXPORT_DIR}/${EXPORT_FILE_BASE}.csv"
  fi
  if [[ $? != 0 ]]; then
    echo " ! Failed to munge java report output"
    exit 1
  fi
  # echo " - All done. Report is here: ${EXPORT_DIR}/${EXPORT_FILE_BASE}.csv"
  # echo " -           See $LOG for details"
  exit 0
  

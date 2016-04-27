#!/bin/bash

export REMOTE=origin
export BRANCH=master
export WORKDIR=Cepave
export GITHUB=$GOPATH/src/github.com
export WORKPATH=$GITHUB/$WORKDIR

#######################################
# Download Source Code
#######################################
rm -fR $GITHUB
mkdir -p $WORKPATH
git clone --quiet -b master https://github.com/Cepave/open-falcon.git $WORKPATH
cd $WORKPATH && git submodule update --quiet --remote --init \
  && git submodule foreach --quiet git checkout -f $REMOTE/$BRANCH \
  && git submodule foreach --quiet git submodule update --quiet --remote --init

#######################################
# Parse Arguments
#######################################
for arg in "$@" ; do
  case $arg in
  "agent")
    export BUILD_AGENT=true
    ;;
  "graph")
    export BUILD_GRAPH=true
    ;;
  "query")
    export BUILD_QUERY=true
    ;;
  "dashboard")
    export BUILD_DASHBOARD=true
    ;;
  "sender")
    export BUILD_SENDER=true
    ;;
  "link")
    export BUILD_LINKS=true
    ;;
  "links")
    export BUILD_LINKS=true
    ;;
  "portal")
    export BUILD_PORTAL=true
    ;;
  "hbs")
    export BUILD_HBS=true
    ;;
  "alarm")
    export BUILD_ALARM=true
    ;;
  "fe")
    export BUILD_FE=true
    ;;
  "judge")
    export BUILD_JUDGE=true
    ;;
  "transfer")
    export BUILD_TRANSFER=true
    ;;
  "task")
    export BUILD_TASK=true
    ;;
  "nodata")
    export BUILD_NODATA=true
    ;;
  "aggregator")
    export BUILD_AGGREGATOR=true
    ;;
  "all")
    export BUILD_AGENT=true
    export BUILD_GRAPH=true
    export BUILD_QUERY=true
    export BUILD_DASHBOARD=true
    export BUILD_SENDER=true
    export BUILD_LINKS=true
    export BUILD_PORTAL=true
    export BUILD_HBS=true
    export BUILD_ALARM=true
    export BUILD_FE=true
    export BUILD_JUDGE=true
    export BUILD_TRANSFER=true
    export BUILD_TASK=true
    export BUILD_NODATA=true
    export BUILD_AGGREGATOR=true
    ;;
  *)
    echo -e "Specify one component to build:\nagent\ngraph\nquery\ndashboard\nsender\nlinks\nportal\nhbs\nalarm\nfe\njudge\ntransfer\ntask\nnodata\naggregator"
    exit 1
    ;;
  esac
done


#######################################
# Build, Package, Rename and Collect
#######################################
export PACKDIR=/package
export LOGFILE=$PACKDIR/filelist.txt
rm -fR $PACKDIR
mkdir -p $PACKDIR

function _build() {
  cd $WORKPATH/$1
  go get ./...
  if [ "$2" = "do_build" ] ; then
    ./control build
  fi
  ./control pack
  export PACKFILE=$(find -name "*$1*.gz")
  export NEWFILE="$(echo ${PACKFILE##*/} | sed -e 's/-[.[:alnum:]]*\.tar.gz/.tar.gz/')"
  mv $PACKFILE $PACKDIR/$NEWFILE && \
    echo "Success... $NEWFILE" && \
    echo $PACKFILE >> $LOGFILE
}

function build() {
  _build $1 do_build
}

function pack() {
  _build $1 do_pack
}

# Agent
if [ ! -z $BUILD_AGENT ] && $BUILD_AGENT ; then
  build agent
fi

# Graph
if [ ! -z $BUILD_GRAPH ] && $BUILD_GRAPH ; then
  export GODEBUG=cgocheck=0
  build graph
fi

# Query
if [ ! -z $BUILD_QUERY ] && $BUILD_QUERY ; then
  build query
fi

# Dashboard
if [ ! -z $BUILD_DASHBOARD ] && $BUILD_DASHBOARD ; then
  pack dashboard
fi

# Sender
if [ ! -z $BUILD_SENDER ] && $BUILD_SENDER ; then
  build sender
fi

# Links
if [ ! -z $BUILD_LINKS ] && $BUILD_LINKS ; then
  pack links
fi

# Portal
if [ ! -z $BUILD_PORTAL ] && $BUILD_PORTAL ; then
  pack portal
fi

# Heartbeat Server (HBS)
if [ ! -z $BUILD_HBS ] && $BUILD_HBS ; then
  build hbs
fi

# Alarm
if [ ! -z $BUILD_ALARM ] && $BUILD_ALARM ; then
  build alarm
fi

# FE
if [ ! -z $BUILD_FE ] && $BUILD_FE ; then
  build fe
fi

# Judge
if [ ! -z $BUILD_JUDGE ] && $BUILD_JUDGE ; then
  build judge
fi

# Transfer
if [ ! -z $BUILD_TRANSFER ] && $BUILD_TRANSFER ; then
  build transfer
fi

# Task
if [ ! -z $BUILD_TASK ] && $BUILD_TASK ; then
  build task
fi

# Nodata
if [ ! -z $BUILD_NODATA ] && $BUILD_NODATA ; then
  build nodata
fi

# Aggregator
if [ ! -z $BUILD_AGGREGATOR ] && $BUILD_AGGREGATOR ; then
  build aggregator
fi


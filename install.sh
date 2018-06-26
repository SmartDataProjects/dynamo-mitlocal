#!/bin/bash

## THIS DIRECTORY

SOURCE=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

## DYNAMO SOURCE

DYNAMO=$1

if [ -z "$DYNAMO" ] || ! [ -d $DYNAMO ]
then
  echo "Usage: install.sh DYNAMO"
  exit 1
fi

## DYNAMO CONFIGURATION

INSTALL_CONF=$2
[ -z "$INSTALL_CONF" ] && INSTALL_CONF=$DYNAMO/dynamo.cfg

if ! [ -e $INSTALL_CONF ]
then
  echo
  echo "$INSTALL_CONF does not exist."
  exit 1
fi

## PLACE ITEMS REQUIRED BEFORE INSTALLATION

rm -rf $SOURCE/.tmp
mkdir $SOURCE/.tmp
CLEANUP_LIST=

for OBJ in mysql config
do
  # List of files we are adding to $DYNAMO
  CLEANUP_LIST=$CLEANUP_LIST" "$(diff -rq $SOURCE/$OBJ $DYNAMO/$OBJ | sed -n "s|^Only in $SOURCE/\(.*\): \(.*\)|\1/\2|p")
  REPLACE_LIST=$(diff -rq $SOURCE/$OBJ $DYNAMO/$OBJ | sed -n "s|^Files .* and $DYNAMO/\(.*\) differ|\1|p")

  for FILE in $REPLACE_LIST
  do
    mkdir -p $SOURCE/.tmp/$(dirname $FILE)
    mv $DYNAMO/$FILE $SOURCE/.tmp/$FILE
  done

  cp -rf $SOURCE/$OBJ $DYNAMO/
done

## INSTALL STANDARD DYNAMO

$DYNAMO/install.sh $INSTALL_CONF || exit 1

## RESTORE THE STANDARD INSTALLATION DIRECTORY

for FILE in $CLEANUP_LIST
do
  rm -f $DYNAMO/$FILE
done

cp -rf $SOURCE/.tmp/* $DYNAMO/

## COPY POST-INSTALL ITEMS

source $DYNAMO/utilities/shellutils.sh

READCONF="$DYNAMO/utilities/readconf -I $INSTALL_CONF"

CLIENT_PATH=$($READCONF paths.client_path)

# Libraries
for PYPATH in $(python -c 'import sys; print " ".join(sys.path)')
do
  if [[ $PYPATH =~ ^/usr/lib/python.*/site-packages$ ]]
  then
    cp -rf $SOURCE/lib/* $PYPATH/dynamo/
    python -m compileall $PYPATH/dynamo > /dev/null
    break
  fi
done

# CLIs
for FILE in $(ls $SOURCE/bin)
do
  cp -f $SOURCE/bin/$FILE $CLIENT_PATH/$FILE
  chmod 755 $CLIENT_PATH/$FILE
done

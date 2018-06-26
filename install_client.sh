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

## INSTALL STANDARD DYNAMO

$DYNAMO/install_client.sh $INSTALL_CONF || exit 1

## COPY POST-INSTALL ITEMS

source $DYNAMO/utilities/shellutils.sh

READCONF="$DYNAMO/utilities/readconf -I $INSTALL_CONF"

CLIENT_PATH=$($READCONF paths.client_path)

# CLIs
for FILE in $(ls $SOURCE/bin)
do
  sed "s|_PYTHON_|$(which python)|" $SOURCE/bin/$FILE > $CLIENT_PATH/$FILE
  chmod 755 $CLIENT_PATH/$FILE
done

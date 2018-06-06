#!/bin/bash

SOURCE=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

for OBJ in $(ls $SOURCE)
do
  [ $OBJ = "install.sh" ] && continue
  [ $OBJ = "dynamo" ] && continue
  cp -r $OBJ dynamo/
done

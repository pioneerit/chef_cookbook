#!/bin/sh

DIR="/backup/"
DAYS="14"

result=`find $DIR -type f -mtime $DAYS`

if [ "x$result" != "x" ]
then
  echo "Stale backups found:"
  echo
  for i in $result
  do
    ls -l $i | cut -d' ' -f6-
  done
fi

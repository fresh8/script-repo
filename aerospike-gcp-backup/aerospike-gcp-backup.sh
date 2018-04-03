#!/usr/bin/env bash

DATE=$(date +%Y%m%d_%H%M)
NAMESPACE=$1
BUCKET=$2
HOST=$3

if [ "$NAMESPACE" == "" ]; then
    echo "Namespace required"
    exit 1
fi
if [ "$BUCKET" == "" ]; then
    echo "Namespace required"
    exit 1
fi
if [ "$HOST" == "" ]; then
    HOST=localhost
fi

OUTPUT_FILE="/tmp/$DB_NAME-dump_$DATE.asb"

asbackup --host $HOST --namespace $NAMESPACE --output-file - > $OUTPUT_FILE
LAST_MD5_FILE="/tmp/$DB_NAME-dump-md5"
if [ -f "$LAST_MD5_FILE" ]; then
  CURRENT_MD5=$(md5sum $OUTPUT_FILE | awk '{ print $1 }')
  LAST_MD5=$(cat "$LAST_MD5_FILE")

  if [ "$CURRENT_MD5" == "$LAST_MD5" ]
  then
    echo "No need to upload; no database content change"
    exit 0
  fi
fi

bzip2 -c $OUTPUT_FILE > "$OUTPUT_FILE.bz2"
echo "$CURRENT_MD5" > "$LAST_MD5_FILE"

gsutil -m -h "Cache-Control:no-cache" cp -r "$OUTPUT_FILE.bz2" "gs://$BUCKET/"

# Remove temporary files
rm $OUTPUT_FILE $OUTPUT_FILE.bz2

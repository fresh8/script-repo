# Aerospike Backup to GCP

## TL;DR
A script for backing up Aerospike namespaces on GCP, only once content has changed,
and compressed for reduced size.

## Prerequisites

### Create the bucket

The bucket will need to exist before running the script. Instructions to create
a bucket are listed on [GCP Storage](https://cloud.google.com/storage/docs/creating-buckets).

### Aerospike tools

This script relies on asbackup and pg_dump being installed on the path. If you're
running this from a machine that is not an Aerospike server, ensure these tools are installed.

## Usage

Download the script to where you want to run it by cloning the repo or just
getting the file.
`wget https://raw.githubusercontent.com/fresh8/script-repo/master/aerospike-gcp-backup/aerospike-gcp-backup.sh`

Update the permissions to allow for execution
`chmod +x aerospike-gcp-backup.sh`

Run the script
`NAMESPACE=<namespace> BUCKET=<bucket name> HOST=<host> ./aerospike-gcp-backup.sh`

*note: if no host is passed localhost is assumed 

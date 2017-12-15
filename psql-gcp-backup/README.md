# PostgreSQL Backup to GCP

## TL;DR
A script for backing up PSQL databases on GCP, only once content has changed,
and gzipped for reduced size.

## Prerequisites

### Create the bucket

The bucket will need to exist before running the script. Instructions to create
a bucket are listed on [GCP Storage](https://cloud.google.com/storage/docs/creating-buckets).

### pg tools

This script relies on psql and pg_dump being installed on the path. If you're
running this from a machine which the database isn't being run on, ensure they
are installed.

## Usage

Download the script to where you want to run it by cloning the repo or just
getting the file.
`wget https://raw.githubusercontent.com/fresh8/script-repo/master/psql-gcp-backup/psql-gcp-backup.sh`

Update the permissions to allow for execution
`chmod +x psql-gcp-backup.sh`

Run the script
`./psql-gcp-backup.sh <db name> <bucket name> <db host> <db user>`

*note: if no db host is passed localhost is assumed and if no db user postgres is assumed*

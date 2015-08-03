#!/bin/bash
# Backup redmine instance to AWS S3 with backup rotation
# http://docs.aws.amazon.com/cli/latest/reference/s3/index.html

config=$(dirname ${BASH_SOURCE[0]})/config.sh
source $config || { echo "ERROR: can not load config"; exit 1; }

label=$(date +%Y-%m-%d-%H-%M-%S)

set -e
set -x

# Backup files
dest="$DIR/files-$label".tar.gz
tar czf "$dest" "$REDMINE_FILES"
# Encrypt files
gpg $GPG_ARGS --encrypt --recipient "$GPG_USER" --output "$dest".gpg "$dest"
# Remove unencrypted files
rm "$dest"


# Backup MySQL
dest="$DIR/mysql-$label"
innobackupex --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --compress --no-timestamp "$dest"
# Encrypt MySQL backup
find "$dest" -type f | while read file; do
        gpg $GPG_ARGS --encrypt --recipient "$GPG_USER" --output "$file".gpg "$file"
        rm "$file"
done

# Rotate old backups
old_files=$(ls -1dt "$DIR"/files* | sed "1,${ROTATE}d")
old_mysql=$(ls -1dt "$DIR"/mysql* | sed "1,${ROTATE}d")
[ -n "$old_files" ] && rm $old_files
[ -n "$old_mysql" ] && rm $old_mysql -r

# Upload backup to AWS S3
region=$(aws s3api get-bucket-location --output text --bucket unitpay.s3.backup-redmine)
aws s3 sync --delete "$DIR" s3://"$AWS_BUCKET"/ --region "$region"


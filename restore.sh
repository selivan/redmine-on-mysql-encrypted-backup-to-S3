#!/bin/bash
# Restore redmine instance from AWS S3 encrypted backup
# Usage: $0 file-backup-to-restore mysql-backup-to-restore

config=$(dirname ${BASH_SOURCE[0]})/config.sh
source $config || { echo "ERROR: can not load config"; exit 1; }

#set -e
set -x

region=$(aws s3api get-bucket-location --output text --bucket unitpay.s3.backup-redmine)

files=$1
mysql=$0

set +x
# If no backup specified - list all possible
if [ -z "$files" -o -z "$mysql" ]; then
        echo "Usage: $0 file-backup-to-restore mysql-backup-to-restore"
        echo "Avaliable archives:"
        aws s3 ls s3://unitpay.s3.backup-redmine/ --region "$region"
        exit 0
fi
set -x


# Ask for private key to decrypt backup
echo "Insert armored(ASCII) private key for $GPG_USER to decrypt backup. Finish with ^D"
gpg $GPG_ARGS --allow-secret-key-import --import --

# Fetch backup
rm "$DIR/$files"
rm "$DIR/$mysql" -r
mkdir "$DIR/$mysql" 
aws s3 cp "s3://$AWS_BUCKET/$files" "$DIR" --region "$region"
aws s3 sync "s3://$AWS_BUCKET/$mysql" "$DIR/$mysql" --region "$region"
# Decrypt backup
files_nogpg=$(echo $files | sed 's/\.gpg$//')
gpg $GPG_ARGS --output "$DIR"/"$files_nogpg" --decrypt "$DIR"/"$files"
rm "$DIR"/"$files"
find "$DIR"/"$mysql" -type f | while read file; do
        name=$(echo $file | sed 's/\.gpg$//')
        gpg $GPG_ARGS --output "$name" --decrypt "$file"
        rm "$file"
done
rm "$GPG_SECRET_KEYRING"

# Restore backup
stop redmine
tar xzf "$DIR"/"$files_nogpg" -C /
chown -R "$REDMINE_SYS_USER": "$REDMINE_FILES"

service mysql stop
innobackupex --decompress "$DIR"/"$mysql"
innobackupex --apply-log --use-memory=512M "$DIR"/"$mysql"
rm "$MYSQL_DATA_DIR"/* -r
cp -ar "$DIR"/"$mysql"/* "$MYSQL_DATA_DIR"
chown -R "$MYSQL_SYS_USER": "$MYSQL_DATA_DIR"

service mysql start
start redmine

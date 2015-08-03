export AWS_ACCESS_KEY_ID="*********************"
export AWS_SECRET_ACCESS_KEY="****************************************"
AWS_BUCKET="org.name.backup-redmine"

MYSQL_USER="innobackupex"
MYSQL_PASSWORD="********************"
MYSQL_SYS_USER="mysql"
MYSQL_DATA_DIR="/var/lib/mysql"

REDMINE_FILES="/opt/redmine/application"
REDMINE_SYS_USER="redmine"

GPG_USER="robot-backup-redmine@unitpay.ru"
GPG_KEYRING=/opt/redmine/scripts/backup-redmine.pub
GPG_SECRET_KEYRING=/opt/redmine/scripts/backup-redmine.key
GPG_ARGS="--no-default-keyring --keyring=$GPG_KEYRING --secret-keyring=$GPG_SECRET_KEYRING --trust-model always --compress-algo none --cipher-algo AES256 --digest-algo SHA512"

# Number of backups to rotate
ROTATE="5"
# Work dir
DIR="/opt/redmine/backup"


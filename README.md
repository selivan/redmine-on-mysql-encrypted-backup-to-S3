Simple scripts to backup and restore redmine+mysql instance to AWS S3.

Backup is encrypted by public gpg key, to restore backup, you should have private key. `innobackupex` is used to backup mysql.

Don't forget to set strict permissions on `config.sh`, it contains sensitive information.

**P.S.** If this code is useful for you - don't forget to put a star on it's [github repo](https://github.com/selivan/redmine-on-mysql-encrypted-backup-to-S3).

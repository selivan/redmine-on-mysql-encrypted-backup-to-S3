Simple scripts to backup and restore redmine+mysql instance to AWS S3.

Backup is encrypted by public gpg key, to restore backup, you should have private key. `innobackupex` is used to backup mysql.

Don't forget to set strict permissions on `config.sh`, it contains sensitive information.

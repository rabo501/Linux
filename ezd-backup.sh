#!/bin/bash

# Dane do logowania
NAS_USER="user1"
NAS_PASS="password01"
NAS_SHARE="//192.168.55.4/backup"
MOUNT_POINT="/mnt/synology_backup"

# Dane do bazy
PG_USER="postgres"
PG_DB="nazwa_bazy"
PG_HOST="localhost"
PG_PASS="twoje_haslo_do_bazy"

# Nazwa pliku backupu z datą
BACKUP_FILE="pg_backup_$(date +%Y-%m-%d_%H-%M-%S).sql"

# Tworzenie katalogu montowania, jeśli nie istnieje
mkdir -p "$MOUNT_POINT"

# Montowanie udziału sieciowego
mount -t cifs "$NAS_SHARE" "$MOUNT_POINT" -o username=$NAS_USER,password=$NAS_PASS

if [ $? -ne 0 ]; then
  echo "Błąd montowania udziału sieciowego!"
  exit 1
fi

# Tworzenie backupu
PGPASSWORD="$PG_PASS" pg_dump -U $PG_USER -h $PG_HOST $PG_DB > "/tmp/$BACKUP_FILE"

if [ $? -ne 0 ]; then
  echo "Błąd backupu bazy!"
  umount "$MOUNT_POINT"
  exit 2
fi

# Przeniesienie backupu na NAS
mv "/tmp/$BACKUP_FILE" "$MOUNT_POINT/"

if [ $? -eq 0 ]; then
  echo "Backup zapisany na NAS: $MOUNT_POINT/$BACKUP_FILE"
else
  echo "Błąd kopiowania backupu na NAS!"
fi

# Kasowanie backupów starszych niż 30 dni
find "$MOUNT_POINT/" -type f -name "pg_backup_*.sql" -mtime +30 -exec rm {} \;

# Odmontowanie udziału
umount "$MOUNT_POINT"

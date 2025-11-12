#!/bin/bash

# Wczytaj dane logowania z pliku
source /home/twojuser/nas_credentials

# Parametry NAS
NAS_SHARE="//192.168.55.4/backup"
MOUNT_POINT="/mnt/synology_backup"

# Parametry bazy
PG_USER="postgres"
PG_DB="nazwa_bazy"
PG_HOST="localhost"

# Nazwa pliku backupu z datą
BACKUP_FILE="pg_backup_$(date +%Y-%m-%d_%H-%M-%S).sql"

# Plik logu
LOG_FILE="/home/twojuser/pg_backup_log.txt"

# Funkcja logująca
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "----- START BACKUP -----"

# Tworzenie katalogu montowania, jeśli nie istnieje
mkdir -p "$MOUNT_POINT"

# Montowanie udziału sieciowego
mount -t cifs "$NAS_SHARE" "$MOUNT_POINT" -o username=$NAS_USER,password=$NAS_PASS
if [ $? -ne 0 ]; then
    log "Błąd montowania udziału sieciowego!"
    exit 1
fi
log "Udział sieciowy zamontowany."

# Tworzenie backupu
PGPASSWORD="$PG_PASS" pg_dump -U $PG_USER -h $PG_HOST $PG_DB > "/tmp/$BACKUP_FILE"
if [ $? -ne 0 ]; then
    log "Błąd backupu bazy!"
    umount "$MOUNT_POINT"
    exit 2
fi
log "Backup bazy utworzony: /tmp/$BACKUP_FILE"

# Przeniesienie backupu na NAS
mv "/tmp/$BACKUP_FILE" "$MOUNT_POINT/"
if [ $? -eq 0 ]; then
    log "Backup zapisany na NAS: $MOUNT_POINT/$BACKUP_FILE"
else
    log "Błąd kopiowania backupu na NAS!"
fi

# Kasowanie backupów starszych niż 30 dni
find "$MOUNT_POINT/" -type f -name "pg_backup_*.sql" -mtime +30 -exec rm {} \;
log "Usunięto backupy starsze niż 30 dni (jeśli były)."

# Odmontowanie udziału
umount "$MOUNT_POINT"
log "Udział sieciowy odmontowany."
log "----- KONIEC BACKUPU -----"

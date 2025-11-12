Utwórz plik /home/twojuser/nas_credentials z zawartością:

    NAS_USER="user1"
    NAS_PASS="password01"
    PG_PASS="twoje_haslo_do_bazy"

Nadaj mu uprawnienia:
    chmod 600 /home/twojuser/nas_credentials

<b>Jak używać </b>

    Uzupełnij w pliku z hasłami prawdziwe dane.
    Podmień PG_DB na nazwę swojej bazy.
    Nadaj skryptowi prawa do wykonania:

    chmod +x pg_backup_to_synology.sh

    Uruchom skrypt:

    ./pg_backup_to_synology.sh


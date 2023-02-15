Linux rendszerek növekményes mentése, az rsync segítségével.
Viszonylag alacsony tárhely és sávszélesség igénnyel.

Használata:

A backup.sh ill. a backup_host_init.sh scriptek elején vannak megadva a munka könyvtárak. A backup.sh-ban:

DIR=/srv/backup

BIN=/usr/local/sbin

OUT=/var/log/backup_out.log

export DATA=/var/lib/backup

export LOG=/var/log/backup.log

A $DIR a mentések könyvtára, a $BIN a scriptek könyvtára, a $OUT az rsync kimenetének a cél fájlja,
a $DATA munka könyvtár (számlálók, exclude fájlok), $LOG a log cél fájl path.

Az inicializáló script önálló script, így az elérési utak ott is modosítandóak:

DIR=/srv/backup

DATA=/var/lib/backup

LOG=/var/log/backup_init.log


A scripteket másoljuk a /usr/local/sbin/ könyvtárba.

Hozzuk létre a /var/lib/backup könyvtárat, és a /srv/backup könyvtárat,
vagy amiket megadtunk a $DATA és $DIR változókban.

Másoljuk a munka könyvtárba az exclude-default.txt fájlt (esetleg modosítsuk), amiben megadhatjuk, hogy mit nem kell menteni.

Ha eddig nem tettük, akkor hozzunk létre egy kulcspárt az ssh eléréshez, az ssh-keygen parancs kiadásával.

Jegyezzük be a crontab-ba, hogy a backup.sh minden nap (praktikusan éjel) fusson le.

Egy gép mentéséhez a következő lékéseket kell megtennünk:

Jegyezzük be a /etc/hosts fájlba a mentendő gép rövid nevét, és címét. Ez a rövid név lesz a könyvtár neve a $DIR-ban ahova a mentést végezzük.

A cél gépen engedélyezni kell a az ssh szerveren az RSA authentikációt:

RSAAuthentication yes

PubkeyAuthentication yes

AuthorizedKeysFile     .ssh/authorized_keys

Át kell másolni a mentő szerverről a fentebb, root felhasználóként generált publikus kulcsot /root/.ssh/id_rsa.pub a cél gépre,
és hozzáfüzni a cél gépen a /root/.ssh/authorized_keys fájlhoz (vagy átnevezni, ha nincs). Ezzel engedélyeztük a mentő szerver root
felhasználójának, hogy belépjen a mentendő szerverre root felhaszálóként jelszó nélkül. Ezt próbáljuk is ki.

Ha működik a bejelentkezás, akkor futtatni kell a backup_host_init.sh scriptet paraméterként megadva a mentendő gép nevét.
A script elvégzi az első mentést. Ha a $DIR-ben létrejött a gép névvel azonos nevű könyvtár, akkor a backup.sh elvégzi a növekményes mentést.

Az aktuális mentés könyvtárneve azonos a mentett host nevével, a régebbi  ek nevei rendre <host>.1 ... <host>.8, <host>.A1 .. <host>.A8, <host>.B1 .. <host>.B8
A mentések rendre egyre régebbiek. A számozott kiterjesztésüek napi, az Ax kiterjesztésüek 8 napi a Bx kiterjesztésüek 64 napi mentések, feltételezve, hogy a
backup.sh naponta fut.

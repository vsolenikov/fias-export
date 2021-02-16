#!/bin/bash
#Works only on debian-based machines!
#sudo apt install dbf2mysql before run

okato = ""
kod_goroda = ""
sudo apt install dbf2mysql

sudo wget https://fias-file.nalog.ru/downloads/2021.02.09/fias_dbf.zip
sudo unzip fias_dbf.zip ADDROB64.DBF
#!sudo rmdir fias_dbf.zip

indir="./"
dblogin="root"
dbpass="yourpassword"
db="fias"
host="localhost"
postfix=".DBF"
prefix="./"

useradm="root"
passadm="vova200027"


cd $indir
for file in `find ./ -type f -name "*$postfix"`
do
    table_tmp=${file%$postfix}
    table_tmp=${table_tmp#$prefix}
            table=${table_tmp,,}
    echo "WORK WITH :$table"
        dbf2mysql -vvv -d $db -t $table -c -h $host -P $dbpass -U $dblogin $file
    mysqldump -u$dblogin -p$dbpass --default-character-set=latin1 $db $table>/tmp/$table.sql
            iconv -f cp866 -t utf-8 /tmp/$table.sql>/tmp/$table.outtmp.sql
    more /tmp/$table.outtmp.sql|sed 's/latin1/utf8/'>/tmp/$table.out.sql
            mysql -u$dblogin -p$dbpass -T --show-warning -e "delete from $table" $db
    mysql -u$dblogin -p$dbpass -T --show-warning $db</tmp/$table.out.sql
        #   break
rm /tmp/$table.out.sql&rm /tmp/$table.outtmp.sql&rm $file
done

sudo mysql -u $useradm -p$passadm <<EOF
SELECT OKATO,CONCAT(SHORTNAME, ' ', OFFNAME) from addrob62 where OKATO LIKE '%61225%' GROUP BY OFFNAME
SELECT CODE,NAME FROM OKATO WHERE CODE LIKE '%61225%'
SELECT house62.OKATO,house62.HOUSENUM, CONCAT(addr.SHORTNAME, ' ', addr.OFFNAME), addr.AOGUID,addr.POSTALCODE FROM house62 LEFT JOIN addrob62 addr ON addr.AOGUID=house62.AOGUID where addr.ACTSTATUS=1 AND addr.OKATO LIKE '%61225%' AND house62.OKATO LIKE '%61225%'
EOF

chmod +x export.sh
./export.sh
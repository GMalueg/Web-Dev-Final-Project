SELECT * FROM cards
INTO OUTFILE 'export/cards.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT * FROM groups
INTO OUTFILE 'export/groups.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT * FROM sports
INTO OUTFILE 'export/sports.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- https://hevodata.com/learn/mysql-export-database-command-line/#meth2
mysqldump -u USER_NAME -p DB_NAME table1 table2 > file_name

-- Example command to log in/start console
/usr/local/mysql/bin/mysql -u root -p --password=root1234 --user=root
-- Example command to log in/start console

-- Exporting existing tables into SQL files (just use INSERT statements)
/usr/local/mysql/bin/mysqldump -u root -p --password=root1234 --user=root gmaluegfp cards > cards.sql
/usr/local/mysql/bin/mysqldump -u root -p --password=root1234 --user=root gmaluegfp sports > sports.sql
/usr/local/mysql/bin/mysqldump -u root -p --password=root1234 --user=root gmaluegfp users > users.sql
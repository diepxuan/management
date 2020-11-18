STOP SLAVE;
STOP REPLICA;

flush status;
flush logs;
flush relay logs;
truncate table mysql.slave_master_info;
reset slave all;
RESET REPLICA ALL;

CHANGE MASTER TO MASTER_HOST='dx1.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123' FOR CHANNEL 'server-1';
CHANGE MASTER TO MASTER_HOST='dx2.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123' FOR CHANNEL 'server-2';
CHANGE MASTER TO MASTER_HOST='dx3.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123' FOR CHANNEL 'server-3';

reset slave;
START SLAVE;
SHOW SLAVE STATUS;


-- SET GLOBAL validate_password.policy=LOW;
-- CREATE USER 'slave' IDENTIFIED WITH mysql_native_password BY 'ductn@123';
-- GRANT REPLICATION SLAVE ON *.* TO 'slave';
-- GRANT ALL PRIVILEGES ON * . * TO 'sa';
-- SET GLOBAL validate_password.policy=MEDIUM;
-- FLUSH PRIVILEGES;

STOP SLAVE;

flush status;
flush logs;
flush relay logs;
truncate table mysql.slave_master_info;
reset slave all;

CHANGE MASTER TO MASTER_HOST='server.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123' FOR CHANNEL 'server-1';
CHANGE MASTER TO MASTER_HOST='server2.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123' FOR CHANNEL 'server-2';
CHANGE MASTER TO MASTER_HOST='server3.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123' FOR CHANNEL 'server-3';

reset slave;
START SLAVE;
SHOW SLAVE STATUS;

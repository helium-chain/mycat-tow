/*!40101 SET NAMES utf8 */;

-- 创建itcast用户，并设置密码，该用户可在任意主机连接该MySQL服务
CREATE USER 'masterSlave'@'%' IDENTIFIED WITH mysql_native_password BY '123456';

-- 为 'master'@'%' 用户分配主从复制权限
GRANT REPLICATION SLAVE ON *.* TO 'masterSlave'@'%';

FLUSH PRIVILEGES;

create database IF NOT EXISTS shopping CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

create database IF NOT EXISTS logs CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
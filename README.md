- mycat - mysql 双主双从，读写分离

| 名称 | IP | 端口 |
| :-: | :-: | :-: |
| MyCat | 172.16.0.10 | 8066,9066 |
| M1 | 172.16.0.101 | 3306 |
| M2 | 172.16.0.102 | 3307 |
| S1 | 172.16.0.103 | 3308 |
| S2 | 172.16.0.103 | 3309 |

- 请先删除{master01,master02,slave01,slave02}/data/ 文件下的所有数据(你需要保持一个空的挂载目录)。
- mycat/data 目录里是初始化sql数据。

1. 启动服务
```sh
$ docker-compose -p master-slave up -d
```

2. 在M1和M2上执行：
```sql
-- 创建itcast用户，并设置密码，该用户可在任意主机连接该MySQL服务
CREATE USER 'masterSlave'@'%' IDENTIFIED WITH mysql_native_password BY '123456';

-- 为 'master'@'%' 用户分配主从复制权限
GRANT REPLICATION SLAVE ON *.* TO 'masterSlave'@'%';

FLUSH PRIVILEGES;

show master status;
    -- M1:
    --  File: mysql-bin.000003
    --  Position: 194

    -- M2:
    --  File: mysql-bin.000003
    --  Position: 194
```

3. S1和S2上执行，主从关联：
```sql
CHANGE MASTER TO MASTER_HOST='mysql-master01', MASTER_USER='masterSlave',
MASTER_PASSWORD='123456', MASTER_LOG_FILE='mysql-bin.000003',
MASTER_LOG_POS=194;

-- 开启主从复制
start slave;

-- 查看同步状态，主库S1/S2中查看。
show slave status \G;
    -- Slave_IO_Running: Yes
    -- Slave_SQL_Running: Yes
```

4. 两主库相互复制，M2 复制 M1，M1 复制 M2。

```sql
-- M1上执行
CHANGE MASTER TO MASTER_HOST='mysql-master02', MASTER_USER='masterSlave',
MASTER_PASSWORD='123456', MASTER_LOG_FILE='mysql-bin.000003',
MASTER_LOG_POS=194;

start slave;
show slave status \G;
    -- Slave_IO_Running: Yes
    -- Slave_SQL_Running: Yes

-- M2上执行
CHANGE MASTER TO MASTER_HOST='mysql-master01', MASTER_USER='masterSlave',
MASTER_PASSWORD='123456', MASTER_LOG_FILE='mysql-bin.000003',
MASTER_LOG_POS=194;

start slave;
show slave status \G;
    -- Slave_IO_Running: Yes
    -- Slave_SQL_Running: Yes
```

5. 分别在两台主库M1、M2上执行DDL、DML语句，查看涉及到的数据库服务器的数据同步情况。
```sql
-- M1 shopping库 执行，会同步到三个其他库

create table tb_user(
    id int(11) not null primary key ,
    name varchar(50) not null,
    sex varchar(1)
)engine=innodb default charset=utf8mb4;

insert into tb_user(id,name,sex) values(1,'Tom','1');
insert into tb_user(id,name,sex) values(2,'Trigger','0');
insert into tb_user(id,name,sex) values(3,'Dawn','1');
insert into tb_user(id,name,sex) values(4,'Jack Ma','1');
insert into tb_user(id,name,sex) values(5,'Coco','0');
insert into tb_user(id,name,sex) values(6,'Jerry','1');
```

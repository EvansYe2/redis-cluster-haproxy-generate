for port in $(seq 6380 6385); 
do 
mkdir -p redis-${port}/
mkdir -p redis-${port}/data
touch redis-${port}/redis.conf
cat >redis-${port}/redis.conf <<EOF
    # 节点配置
    # 绑定的主机地址
    bind 0.0.0.0
    # 禁用保护模式，以便允许集群节点之间的通信
    protected-mode no
    # 启用守护进程后，Redis会把pid写到一个pidfile中，在/var/run/redis.pid
    daemonize no
    # 当Redis以守护进程方式运行时，Redis默认会把pid写入/var/run/redis.pid文件，可以通过pidfile指定
    pidfile /var/run/redis.pid
    # 指定Redis监听端口，默认端口为6379
    # 如果指定0端口，表示Redis不监听TCP连接
    port ${port}
    # 当客户端闲置多长时间后关闭连接，如果指定为0，表示关闭该功能
    timeout 0
    # 指定日志记录级别，Redis总共支持四个级别：debug、verbose、notice、warning，默认为verbose
    # debug (很多信息, 对开发／测试比较有用)
    # verbose (many rarely useful info, but not a mess like the debug level)
    # notice (moderately verbose, what you want in production probably)
    # warning (only very important / critical messages are logged)
    loglevel verbose
    # 日志记录方式，默认为标准输出，如果配置为redis为守护进程方式运行，而这里又配置为标准输出，则日志将会发送给/dev/null
    logfile redis.log

    #maxmemory 8gb
    #maxmemory-policy allkeys-lru

    ################################ SNAPSHOTTING  #################################
    # RDB存储配置
    # 指定在多长时间内，有多少次更新操作，就将数据同步到数据文件，可以多个条件配合
    # Save the DB on disk:
    #
    #   save <seconds> <changes>
    #
    #   Will save the DB if both the given number of seconds and the given
    #   number of write operations against the DB occurred.
    #
    #   满足以下条件将会同步数据:
    #   900秒（15分钟）内有1个更改
    #   300秒（5分钟）内有10个更改
    #   60秒内有10000个更改
    #   Note: 可以把所有“save”行注释掉，这样就取消同步操作了
    save 900 1
    save 300 10
    save 60 10000
    # 指定存储至本地数据库时是否压缩数据，默认为yes，Redis采用LZF压缩，如果为了节省CPU时间，可以关闭该选项，但会导致数据库文件变的巨大
    rdbcompression yes
    # 指定本地数据库文件名，默认值为dump.rdb
    dbfilename dump.rdb
    # 指定本地数据库存放目录，文件名由上一个dbfilename配置项指定
    dir /data

    ################################ REDIS CLUSTER  ###############################
    # 开启集群
    cluster-enabled yes
    # 存储集群节点信息
    cluster-config-file nodes.conf
    # 超时设置    
    cluster-node-timeout 5000            
    ################################# REPLICATION #################################
    # 设置密码
    masterauth 123456789

    ################################## SECURITY ###################################
    # 设置密码
    requirepass 123456789

    ############################## APPEND ONLY MODE ###############################
    # 开启aof配置
    appendonly yes
    # 指定更新日志条件，共有3个可选值：
    # no:表示等操作系统进行数据缓存同步到磁盘（快）
    # always:表示每次更新操作后手动调用fsync()将数据写到磁盘（慢，安全）
    # everysec:表示每秒同步一次（折衷，默认值）
    appendfsync everysec
    # 指定更新日志文件名，默认为appendonly.aof
    appendfilename "appendonly.aof"


    # 宿主机的ip
    cluster-announce-ip 192.168.31.108
    cluster-announce-port ${port}
    cluster-announce-bus-port 1${port}

EOF
# 宿主机的ip
echo "        server redis-${port} 192.168.31.108:${port} check" >> haproxy.cfg

done

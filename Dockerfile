# -------------------------------------------------------------------
# Dockerfile: Single-Container Pseudo-Distributed Hadoop on Ubuntu
# -------------------------------------------------------------------
    FROM ubuntu:22.04

    ENV DEBIAN_FRONTEND=noninteractive
    
    # -------------------------------------------------------------------
    # 1. System Packages & Java
    # -------------------------------------------------------------------
    RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget curl net-tools sudo openssh-server openssh-client \
        vim python3 python3-pip procps software-properties-common \
        tzdata git \
    && rm -rf /var/lib/apt/lists/*
    
    # (Optional) Set up your timezone
    RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata
    
    # Install OpenJDK 8
    RUN apt-get update -y && \
        apt-get install -y openjdk-8-jdk && \
        rm -rf /var/lib/apt/lists/*
    
    ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
    ENV PATH=$PATH:$JAVA_HOME/bin
    
    # -------------------------------------------------------------------
    # 2. Environment Variables for Versions
    # -------------------------------------------------------------------
    ENV HADOOP_VERSION=3.3.2 \
        HIVE_VERSION=3.1.2 \
        HBASE_VERSION=2.4.13 \
        OOZIE_VERSION=5.2.1 \
        INSTALL_DIR=/opt
    
    WORKDIR $INSTALL_DIR
    
    # -------------------------------------------------------------------
    # 3. Install Hadoop
    # -------------------------------------------------------------------
    RUN wget -nv https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
        tar -xzf hadoop-$HADOOP_VERSION.tar.gz && \
        mv hadoop-$HADOOP_VERSION hadoop && \
        rm hadoop-$HADOOP_VERSION.tar.gz
    
    ENV HADOOP_HOME=/opt/hadoop
    ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
    
    # -------------------------------------------------------------------
    # 4. Install Hive
    # -------------------------------------------------------------------
    RUN wget -nv https://dlcdn.apache.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
        tar -xzf apache-hive-$HIVE_VERSION-bin.tar.gz && \
        mv apache-hive-$HIVE_VERSION-bin hive && \
        rm apache-hive-$HIVE_VERSION-bin.tar.gz
    
    ENV HIVE_HOME=/opt/hive
    ENV PATH=$PATH:$HIVE_HOME/bin
    
    # -------------------------------------------------------------------
    # 5. Install HBase
    # -------------------------------------------------------------------
    RUN wget -nv https://dlcdn.apache.org/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz && \
        tar -xzf hbase-$HBASE_VERSION-bin.tar.gz && \
        mv hbase-$HBASE_VERSION hbase && \
        rm hbase-$HBASE_VERSION-bin.tar.gz
    
    ENV HBASE_HOME=/opt/hbase
    ENV PATH=$PATH:$HBASE_HOME/bin
    
    # -------------------------------------------------------------------
    # 6. Install Oozie
    # -------------------------------------------------------------------
    RUN wget -nv https://dlcdn.apache.org/oozie/$OOZIE_VERSION/oozie-$OOZIE_VERSION.tar.gz && \
        tar -xzf oozie-$OOZIE_VERSION.tar.gz && \
        mv oozie-$OOZIE_VERSION oozie && \
        rm oozie-$OOZIE_VERSION.tar.gz
    
    ENV OOZIE_HOME=/opt/oozie
    ENV PATH=$PATH:$OOZIE_HOME/bin
    
    # -------------------------------------------------------------------
    # 7. SSH Setup for Pseudo-Distributed Hadoop
    # -------------------------------------------------------------------
    RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
        cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
        chmod 600 /root/.ssh/authorized_keys && \
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
    
    # -------------------------------------------------------------------
    # 8. Copy Configuration Files
    # -------------------------------------------------------------------
    # Copies your .xml configs into the correct locations
    COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
    COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
    COPY config/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
    COPY config/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
    
    COPY config/hive-site.xml $HIVE_HOME/conf/hive-site.xml
    COPY config/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
    COPY config/oozie-site.xml $OOZIE_HOME/conf/oozie-site.xml
    
    # -------------------------------------------------------------------
    # 9. Copy Scripts to Start Services
    # -------------------------------------------------------------------
    COPY scripts/setup-services.sh /setup-services.sh
    COPY scripts/start-hadoop.sh /start-hadoop.sh
    COPY scripts/start-services.sh /start-services.sh
    
    RUN chmod +x /setup-services.sh /start-hadoop.sh /start-services.sh
    
    # -------------------------------------------------------------------
    # 10. Expose Ports
    # -------------------------------------------------------------------
    # Hadoop (HDFS, YARN)
    EXPOSE 50070 50075 8020 9000 8088
    # Hive (Thrift)
    EXPOSE 10000
    # HBase
    EXPOSE 16010 16030
    # Oozie
    EXPOSE 11000
    
    # -------------------------------------------------------------------
    # 11. Entry Point
    # -------------------------------------------------------------------
    # We'll run 'setup-services.sh' on container startup
    CMD ["/bin/bash", "/setup-services.sh"]
    

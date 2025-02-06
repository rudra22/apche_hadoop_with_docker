# ----------------------------------------------------------------------------
# Dockerfile for a single-container pseudo-distributed Hadoop ecosystem
# (HDFS + YARN, Hive, HBase, Oozie, Hue) on Ubuntu 20.04.
#
# Fixes the package conflict by relying exclusively on the MariaDB dev libraries
# (libmariadb-dev + libmariadb-dev-compat) to provide "my_config.h", etc.
# ----------------------------------------------------------------------------
FROM ubuntu:20.04

# Use noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Set software versions
ENV JAVA_VERSION="8" \
    HADOOP_VERSION="3.3.5" \
    HIVE_VERSION="3.1.3" \
    HBASE_VERSION="2.4.13" \
    OOZIE_VERSION="5.2.1" \
    HUE_VERSION="4.10.0" \
    MAVEN_VERSION="3.8.7"

# ----------------------------------------------------------------------------
# 1) Base system packages
# ----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    ssh \
    pdsh \
    openssh-server \
    openssh-client \
    wget \
    curl \
    vim \
    software-properties-common \
    sudo \
    tzdata \
    locales \
    # Python 2 dev packages for Hue build
    python2 \
    python2-dev \
    python-is-python2 \
    # Keep Python 3 if you wish
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale (optional)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ----------------------------------------------------------------------------
# 2) Install Java (OpenJDK 8)
# ----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y openjdk-8-jdk && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------
# 3) Install Maven (needed for Oozie builds) - from Apache archives
# ----------------------------------------------------------------------------
RUN wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz
ENV MAVEN_HOME=/opt/maven
ENV PATH=${MAVEN_HOME}/bin:${PATH}

# ----------------------------------------------------------------------------
# 4) Install Hadoop 3.3.5 (from Apache archives)
# ----------------------------------------------------------------------------
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt \
    && ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop \
    && rm hadoop-${HADOOP_VERSION}.tar.gz
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# ----------------------------------------------------------------------------
# 5) Install Hive 3.1.3 (from Apache archives)
# ----------------------------------------------------------------------------
RUN wget https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive \
    && rm apache-hive-${HIVE_VERSION}-bin.tar.gz
ENV HIVE_HOME=/opt/hive
ENV PATH=$HIVE_HOME/bin:$PATH

# ----------------------------------------------------------------------------
# 6) Install HBase 2.4.13 (from Apache archives)
# ----------------------------------------------------------------------------
RUN wget https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar xzf hbase-${HBASE_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/hbase-${HBASE_VERSION} /opt/hbase \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz
ENV HBASE_HOME=/opt/hbase
ENV PATH=$HBASE_HOME/bin:$PATH

# ----------------------------------------------------------------------------
# 7) Install Oozie 5.2.1 (from Apache archives)
#    (May require manual sharelib or extra steps in real usage)
# ----------------------------------------------------------------------------
RUN wget https://archive.apache.org/dist/oozie/${OOZIE_VERSION}/oozie-${OOZIE_VERSION}.tar.gz \
    && tar xzf oozie-${OOZIE_VERSION}.tar.gz -C /opt \
    && rm oozie-${OOZIE_VERSION}.tar.gz
ENV OOZIE_HOME=/opt/oozie-${OOZIE_VERSION}
ENV PATH=$OOZIE_HOME/bin:$PATH

# ----------------------------------------------------------------------------
# 8) Additional dependencies (Node.js, libs, etc.)
#    We DO NOT install libmysqlclient-dev due to conflicts with libmariadb-dev
# ----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    libkrb5-dev \
    libssl-dev \
    libldap2-dev \
    libsqlite3-dev \
    libtidy-dev \
    libxml2-dev \
    libxslt-dev \
    g++ \
    make \
    libffi-dev \
    nodejs \
    npm \
    # Only MariaDB dev packages for old MySQL headers
    libmariadb-dev \
    libmariadb-dev-compat \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------
# 9) Python 2 pip bootstrap
# ----------------------------------------------------------------------------
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py \
    && python2 /tmp/get-pip.py \
    && pip2 install --upgrade \
       "pip<21" \
       setuptools==44.1.1 \
       wheel==0.37.1 \
       "setuptools_scm>=1.11.1,<2.0.0" \
    && rm /tmp/get-pip.py

# ----------------------------------------------------------------------------
# 10) Download & build Hue 4.10.0 from source
# ----------------------------------------------------------------------------
RUN wget https://github.com/cloudera/hue/archive/refs/tags/release-${HUE_VERSION}.tar.gz \
    && tar xzf release-${HUE_VERSION}.tar.gz -C /opt \
    && mv /opt/hue-release-${HUE_VERSION} /opt/hue-${HUE_VERSION} \
    && ln -s /opt/hue-${HUE_VERSION} /opt/hue \
    && rm release-${HUE_VERSION}.tar.gz

WORKDIR /opt/hue
# Force build with Python 2.7
RUN make apps PYTHON=python2.7
WORKDIR /

# ----------------------------------------------------------------------------
# 11) Setup SSH for Hadoop
# ----------------------------------------------------------------------------
RUN ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys

# ----------------------------------------------------------------------------
# 12) Copy config files
# ----------------------------------------------------------------------------
COPY configs/hadoop/* $HADOOP_HOME/etc/hadoop/
COPY configs/hive/hive-site.xml $HIVE_HOME/conf/
COPY configs/hbase/hbase-site.xml $HBASE_HOME/conf/
COPY configs/oozie/oozie-site.xml $OOZIE_HOME/conf/
COPY configs/hue/hue.ini /opt/hue/desktop/conf/

# ----------------------------------------------------------------------------
# 13) Copy and set up scripts
# ----------------------------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
COPY scripts/start-hadoop.sh /scripts/start-hadoop.sh
COPY scripts/start-hive.sh /scripts/start-hive.sh
COPY scripts/start-hbase.sh /scripts/start-hbase.sh
COPY scripts/start-oozie.sh /scripts/start-oozie.sh
COPY scripts/start-hue.sh /scripts/start-hue.sh

RUN chmod +x /entrypoint.sh \
    /scripts/start-hadoop.sh \
    /scripts/start-hive.sh \
    /scripts/start-hbase.sh \
    /scripts/start-oozie.sh \
    /scripts/start-hue.sh

# ----------------------------------------------------------------------------
# 14) Expose common ports
# ----------------------------------------------------------------------------
# - 50070: HDFS NameNode Web UI
# - 8088: YARN ResourceManager
# - 8888: Hue
# - 11000: Oozie
EXPOSE 50070 8088 8888 11000

ENTRYPOINT ["/entrypoint.sh"]

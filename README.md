# Hadoop + Hue Single-Container Pseudo-Distributed

This repository demonstrates running **Apache Hadoop (HDFS + YARN), Hive, HBase, Oozie,** and **Hue** within **one Docker container** for **development/testing**.

## Features

- **HDFS (pseudo-distributed)**: Single NameNode + DataNode
- **YARN**: Single ResourceManager + NodeManager
- **Hive**: Using Derby metastore
- **HBase**: Single process (standalone mode)
- **Oozie**: Optional startup
- **Hue**: Provides a web UI for browsing HDFS, running Hive queries, Oozie workflows, HBase, etc.


## How to Build & Run

1. **Build**:

   ```bash
   cd docker
   docker build -t hadoop-hue-in-docker:latest .

2. **Run**

    ```docker run -d \
    --name hadoop-hue \
    -p 50070:50070 \
    -p 8088:8088 \
    -p 10000:10000 \
    -p 16010:16010 \
    -p 11000:11000 \
    -p 8888:8888 \
    hadoop-hue-in-docker:latest


## Check Services:

- NameNode UI: http://localhost:50070
- ResourceManager UI: http://localhost:8088
- Hive: jdbc:hive2://localhost:10000/default
- HBase Master UI: http://localhost:16010
- Oozie: http://localhost:11000/oozie/
- Hue: http://localhost:8888

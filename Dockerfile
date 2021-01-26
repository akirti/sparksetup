From ubuntu:20.10
LABEL author="Akirti" email="ak@ak.com"
LABEL version="0.1"


RUN apt-get update && \
	apt-get install -y python3

# Set for current session
ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TZ="UTC-5" \
    JAVA_VERSION=8 \
    JAVA_UPDATE=202 \
    JAVA_UPDATE_SMALL_VERSION=08 \
    JAVA_BASE_URL=https://download.oracle.com/otn-pub/java \
    JAVA_BASE_MIRRORS_URL=https://repo.huaweicloud.com/java \
    JAVA_HOME=/opt/java \
    PATH=$PATH:${JAVA_HOME}/bin \
    USER_HOME_DIR="/root"

# JAVA
#From ringcentral/jdk:8u202


# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update 
RUN apt-get install -y curl vim wget software-properties-common ssh net-tools ca-certificates git zip subversion sshpass curl jq 


#==============
# Install Oracle JDK
#==============
RUN mkdir -p /opt/java \
    && cd /tmp \
    && wget --no-check-certificate "${JAVA_BASE_MIRRORS_URL}/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_UPDATE_SMALL_VERSION}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" \
    && tar -xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" -C "${JAVA_HOME}" --strip-components=1 \
    && ln -s ${JAVA_HOME}/bin/* /usr/bin/ \
    && rm -rf "${JAVA_HOME}/"*src.zip \
    && wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${JAVA_BASE_URL}/jce/${JAVA_VERSION}/jce_policy-${JAVA_VERSION}.zip" \
    && unzip -jo -d "${JAVA_HOME}/jre/lib/security" "jce_policy-${JAVA_VERSION}.zip" \
    && rm "${JAVA_HOME}/jre/lib/security/README.txt" \
    && rm -rf /tmp/*
    
#==============
# Show version
#==============
RUN java -version \
    && javac -version
    

RUN apt-get update \
 && apt-get install -y curl unzip \
    python3 python3-setuptools python3-pip\
 && ln -s /usr/bin/python3 /usr/bin/python \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install py4j
RUN pip install arcgis==1.8.2
RUN pip install pyspark==3.0.1
RUN pip install pandas==1.1.1
RUN pip install cx_Oracle==8.0.1
RUN pip install sanic==20.9.0
RUN pip install pony==0.7.13
RUN pip install sanic-openapi==0.6.2
RUN pip install requests



# Install maven 3.6.3
ENV MAVEN_VERSION 3.6.3

RUN wget --no-verbose -O /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz http://www-eu.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin  && \
    rm -f /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz

ENV MAVEN_HOME /opt/maven


# GEOSPARK COMPILE and Copy
ENV GSPARK_SRC 1.3.2
ENV GSPARK_VERSION_F 1.3.2-spark-3.0
ENV GSPARK_PACKAGE geospark-${GSPARK_VERSION_F}
ENV GSPARK_HOME /usr/share/${GSPARK_PACKAGE}
RUN echo ${GSPARK_PACKAGE} 
RUN echo https://github.com/apache/incubator-sedona/archive/${GSPARK_VERSION_F}.tar.gz
RUN ls 
RUN echo "--------------------------"
RUN wget --no-verbose  https://github.com/apache/incubator-sedona/archive/${GSPARK_VERSION_F}.tar.gz -O /tmp/${GSPARK_PACKAGE}.tar.gz && \
	mkdir ${GSPARK_HOME} &&\
    tar xzf /tmp/${GSPARK_PACKAGE}.tar.gz  -C  ${GSPARK_HOME} && \
    tar xzf /tmp/${GSPARK_PACKAGE}.tar.gz  -C /tmp/

RUN cd /tmp/incubator-sedona-${GSPARK_VERSION_F} && mvn clean install -DskipTests

ENV EXT_JARS_HOME /usr/share/extlib
RUN mkdir ${EXT_JARS_HOME}

#RUN cp /tmp/incubator-sedona-${GSPARK_VERSION_F}/core/target/*.jar  ${EXT_JARS_HOME}/
#RUN cp /tmp/incubator-sedona-${GSPARK_VERSION_F}/sql/target/*.jar ${EXT_JARS_HOME}/
#RUN cp /tmp/incubator-sedona-${GSPARK_VERSION_F}/viz/target/*.jar ${EXT_JARS_HOME}/

RUN find /tmp/incubator-sedona-${GSPARK_VERSION_F}/core/target/ -type f -name "*.jar" -exec cp {} ${EXT_JARS_HOME}/ \;
RUN find /tmp/incubator-sedona-${GSPARK_VERSION_F}/sql/target/ -type f -name "*.jar" -exec cp {} ${EXT_JARS_HOME}/ \;
RUN find /tmp/incubator-sedona-${GSPARK_VERSION_F}/viz/target/ -type f -name "*.jar" -exec cp {} ${EXT_JARS_HOME}/ \;



ENV CLASSPATH $EXT_JARS_HOME:CLASSPATH

#JDBC Driver
ENV EXT_JARS_HOME /usr/share/extlib
RUN wget "https://download.oracle.com/otn-pub/otn_software/jdbc/199/ojdbc8.jar" -O "/tmp/ojdbc8.jar" && \
	cp /tmp/ojdbc8.jar ${EXT_JARS_HOME}/ojdbc8.jar 
	#cp /tmp/ojdbc8.jar /usr/local/lib/python3.8/dist-packages/pyspark/jars/ojdbc8.jar
	
RUN find ${EXT_JARS_HOME}/ -type f -name "*.jar" -exec cp {}  /usr/local/lib/python3.8/dist-packages/pyspark/jars/ \;

	
# conda environment
#From continuumio/anaconda3
# ANACONDA 3
# https://github.com/apache/incubator-sedona/archive/${}.tar.gz
#RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
#    libglib2.0-0 libxext6 libsm6 libxrender1 \
#    git mercurial subversion

#RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
#    wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh -O ~/anaconda.sh && \
#    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
#    rm ~/anaconda.sh

#RUN apt-get install -y curl grep sed dpkg && \
#    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
#    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
#    dpkg -i tini.deb && \
#    rm tini.deb && \
#    apt-get clean

#ENV PATH /opt/conda/bin:$PATH

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# JAVA
#RUN apt-get update \
# && apt-get install -y openjdk-8-jre \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*




# SCALA
ENV SCALA_VERSION=2.12.10
ENV SCALA_HOME=/usr/share/scala
RUN cd "/tmp" && \
    wget \
    "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    rm -rf "/tmp/"*


# HADOOP
ENV HADOOP_VERSION 2.7.4
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl  \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R root:root $HADOOP_HOME


# SPARK
ENV SPARK_VERSION 3.0.1
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME

RUN find ${EXT_JARS_HOME}/ -type f -name "*.jar" -exec cp {}  /usr/spark-3.0.1/jars/ \;


WORKDIR $SPARK_HOME
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]


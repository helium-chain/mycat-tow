#Mycat
FROM centos:7

# 替换默认的YUM仓库配置
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Base.repo \
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://mirrors.aliyun.com|g' /etc/yum.repos.d/CentOS-Base.repo

# 清除YUM缓存
RUN yum clean all

# 重新生成仓库元数据
RUN yum makecache fast

RUN yum install -y java-1.8.0-openjdk-devel.x86_64 gettext nmap-ncat openssl telnet \
 && yum clean all -y

#Mycat版本
ENV MYCAT_VERSION 1.6.7.3

ENV MYCAT_HOME /home/mycat

COPY ./data/Mycat-server-${MYCAT_VERSION}-release-20210913163959-linux.tar.gz ./

RUN mv ./Mycat-server-${MYCAT_VERSION}-release-20210913163959-linux.tar.gz mycat.tar.gz \
  && tar -zxf mycat.tar.gz \
  && rm -f mycat.tar.gz \
  && mv mycat /home/ \
  && chmod u+x ${MYCAT_HOME}

EXPOSE 8066 9066

ENV PATH=$PATH:$MYCAT_HOME/bin

WORKDIR ${MYCAT_HOME}/bin

CMD ["./mycat","console"]
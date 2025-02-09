FROM amazonlinux:2

# Set working directory to /opt
WORKDIR /opt

# Install Amazon Corretto 17, wget, and tar
RUN yum update -y && yum install -y \
    java-17-amazon-corretto \
    wget \
    tar \
    && yum clean all

# Verify Java installation
RUN java -version

# Download and extract Tomcat 10.1.34
RUN wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz \
    && tar -xvf apache-tomcat-10.1.34.tar.gz \
    && rm apache-tomcat-10.1.34.tar.gz

# Modify context.xml to allow access from any IP
RUN sed -i 's/"127\\.\\d+\\.\\d+\\.\\d+|::1|0:0:0:0:0:0:0:1"/".*"/g' \
    /opt/apache-tomcat-10.1.34/webapps/manager/META-INF/context.xml

# Configure tomcat-users.xml with user and roles
RUN mv /opt/apache-tomcat-10.1.34/conf/tomcat-users.xml /opt/apache-tomcat-10.1.34/conf/bkp_tomcat-users.xml_23Apr24 \
    && echo '<?xml version="1.0" encoding="utf-8"?> \
<tomcat-users> \
    <role rolename="manager-gui"/> \
    <user username="tomcat" password="tomcat" roles="manager-gui,manager-script,manager-status"/> \
</tomcat-users>' > /opt/apache-tomcat-10.1.34/conf/tomcat-users.xml

# Modify server.xml to change the port from 8080 to 8091
RUN sed -i 's/Connector port="8080"/Connector port="8091"/g' /opt/apache-tomcat-10.1.34/conf/server.xml

# Expose the new Tomcat port
EXPOSE 8091

# Start Tomcat server
CMD ["/opt/apache-tomcat-10.1.34/bin/catalina.sh", "run"]

FROM ubuntu as stage1
RUN apt-get update && apt-get install -y wget
RUN wget https://get.jenkins.io/war-stable/2.387.2/jenkins.war -P /home/jenkins/
EXPOSE 8080

FROM ubuntu as stage2
ADD https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.74/bin/apache-tomcat-9.0.74.tar.gz /tomcat/
WORKDIR /tomcat
RUN tar -xzf *.tar.gz && mv apache-tomcat-9.0.74 /opt/tomcat
RUN sed -i 's/<Connector port="8080"/<Connector port="8081"/g' /opt/tomcat/conf/server.xml
COPY context.xml /opt/tomcat/webapps/manager/META-INF/context.xml 
COPY context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
COPY tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
COPY tomcat.service /etc/systemd/system/tomcat.service
EXPOSE 8081

FROM ubuntu as stage3
RUN apt-get update && apt-get install -y fontconfig openjdk-11-jre
COPY --from=stage2 /opt/tomcat /opt/tomcat
COPY --from=stage1 /home/jenkins/ /opt/tomcat/webapps/
EXPOSE 8081
EXPOSE 8080
RUN /opt/tomcat/bin/startup.sh

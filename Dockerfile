# Pull base image 
FROM tomcat:latest
LABEL maintainer="Kelvin Duan" 
MAINTAINER "kelvin_duan@epam.com" 
WORKDIR webapps
COPY /webapp/target/webapp.war .

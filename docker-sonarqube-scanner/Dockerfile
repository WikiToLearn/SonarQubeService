FROM java:8
ENV SONAR_LOGIN=admin \
 SONAR_PASSWORD=

RUN apt-get update && \
 apt-get -y install curl && \
 rm -f /var/cache/apt/archives/*deb && \
 find /var/lib/apt/lists/ -type f -delete && \
 find /var/log/ -type f -delete
RUN apt-get update && \
 apt-get -y install maven && \
 rm -f /var/cache/apt/archives/*deb && \
 find /var/lib/apt/lists/ -type f -delete && \
 find /var/log/ -type f -delete
RUN apt-get update && \
 apt-get -y install --fix-missing && \
 rm -f /var/cache/apt/archives/*deb && \
 find /var/lib/apt/lists/ -type f -delete && \
 find /var/log/ -type f -delete

WORKDIR /root

RUN curl -OL https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-2.6.1.zip && unzip sonar-scanner-2.6.1.zip && rm sonar-scanner-2.6.1.zip

ENV SONAR_RUNNER_HOME=/root/sonar-scanner-2.6.1
ENV PATH $PATH:/root/sonar-scanner-2.6.1/bin

CMD sonar-scanner -Dsonar.projectBaseDir=./src -Dsonar.login=$SONAR_LOGIN -Dsonar.password=$SONAR_PASSWORD

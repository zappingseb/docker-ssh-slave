# The MIT License
#
#  Copyright (c) 2015, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM openjdk:8-jdk
LABEL MAINTAINER="Nicolas De Loof <nicolas.deloof@gmail.com>"

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

# setup SSH server
RUN apt-get update \
    && apt-get install --no-install-recommends -y openssh-server \
    && rm -rf /var/lib/apt/lists/*
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'
RUN apt-get install -y apt-transport-https ca-certificates
RUN apt-get update \
    && apt-get install -y r-base r-cran-rjava
RUN R -e "install.packages(c('ps'), repos='http://cran.uni-muenster.de/')"

RUN R -e "install.packages('tidyverse', repos='http://cran.uni-muenster.de/'))"
RUN R -e "install.packages('boot', repos='http://cran.uni-muenster.de/'))"
RUN R -e "install.packages('RTest', repos='http://cran.uni-muenster.de/'))"

# NTK dependences
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/BiasedUrn/BiasedUrn_1.06.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/epiR/epiR_0.9-93.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/plotrix/plotrix_3.7-1.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN apt-get install -y -t unstable libiodbc2-dev r-cran-rodbc
# RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/RODBC/RODBC_1.3-14.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/pROC/pROC_1.10.0.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/chron/chron_2.3-51.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/chron/chron_2.3-51.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/progress/progress_1.2.0.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/GGally_1.4.0.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/ggcorrplot_0.1.3.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/rlang/rlang_0.3.4.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"

RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/exactRankTests/exactRankTests_0.8-28.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/maxstat/maxstat_0.7-24.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/generics_0.0.2.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"

RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/broom/broom_0.5.1.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"

RUN R -e "install.packages('https://cran.r-project.org/src/contrib/KMsurv_0.1-5.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/km.ci_0.5-2.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"

RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/survMisc/survMisc_0.5.4.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/survminer_0.4.6.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"


VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY setup-sshd /usr/local/bin/setup-sshd

EXPOSE 22

ENTRYPOINT ["setup-sshd"]

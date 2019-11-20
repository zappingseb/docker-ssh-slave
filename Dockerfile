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
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		fonts-texgyre \
	&& rm -rf /var/lib/apt/lists/*

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Use Debian unstable via pinning -- new style via APT::Default-Release
RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
        && echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default
ENV R_BASE_VERSION 3.6.1

## Now install R and littler, and create a link for littler in /usr/local/bin
RUN apt-get update \
	&& apt-get install -t unstable -y --no-install-recommends \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}-* \
		r-base-dev=${R_BASE_VERSION}-* \
		r-recommended=${R_BASE_VERSION}-* \
        r-cran-rjava \
	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/*
RUN R -e "install.packages(c('ps'), repos='http://cran.uni-muenster.de/')"

RUN R -e "install.packages('tidyverse', repos='http://cran.uni-muenster.de/')"
RUN R -e "install.packages('boot', repos='http://cran.uni-muenster.de/')"
RUN R -e "install.packages('RTest', repos='http://cran.uni-muenster.de/')"

# NTK dependences
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/BiasedUrn/BiasedUrn_1.06.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/epiR/epiR_0.9-93.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/plotrix/plotrix_3.7-1.tar.gz',repos=NULL, method='wget', extra='--no-check-certificate')"
RUN apt-get update \
	&& apt-get install -t unstable -y --no-install-recommends libiodbc2-dev r-cran-rodbc
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

RUN R -e "install.packages(c('rlang','gdata', 'GGally', 'gmodels', 'gridExtra', 'Hmisc'), repos='http://cran.uni-muenster.de/')"
RUN R -e "install.packages(c('ggpubr','survminer'), repos='http://cran.uni-muenster.de/')"

# Minimal texlive
## From the Build-Depends of the Debian R package, plus subversion
RUN apt-get update -qq \
	&& apt-get install -t unstable -y --no-install-recommends \
		bash-completion \
		bison \
		debhelper \
		g++ \
		gcc \
		gdb \
		gfortran \
		groff-base \
		libblas-dev \
		libbz2-dev \
		libcairo2-dev/unstable \
		libcurl4-openssl-dev \
		libjpeg-dev \
		liblapack-dev \
		liblzma-dev \
		libncurses5-dev \
		libpango1.0-dev \
		libpcre3-dev \
		libpng-dev \
		libreadline-dev \
		libtiff5-dev \
		libx11-dev \
		libxt-dev \
		mpack \
		subversion \
		tcl8.6-dev \
		texinfo \
		texlive-base \
		texlive-extra-utils \
		texlive-fonts-extra \
		texlive-fonts-recommended \
		texlive-generic-recommended \
		texlive-latex-base \
		texlive-latex-extra \
		texlive-latex-recommended \
		tk8.6-dev \
		x11proto-core-dev \
		xauth \
		xdg-utils \
		xfonts-base \
		xvfb \
		zlib1g-dev

# devtools for check
RUN R -e "install.packages(c('devtools'), repos='http://cran.uni-muenster.de/')"

# Jenkins tasks
VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY setup-sshd /usr/local/bin/setup-sshd

EXPOSE 22

ENTRYPOINT ["setup-sshd"]

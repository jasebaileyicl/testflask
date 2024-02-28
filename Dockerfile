# FROM --platform=linux/amd64 ubuntu:latest
# Docker image with PYTHON3 and DEPENDENCES for pyodbc with MS ODBC 17 DRIVER, Debian GNU/Linux 10 (buster)
# BY TADEO RUBIO
# Using the official Python image, Tag 3.8.3-buster
FROM --platform=linux/amd64  python:3.11.0-buster
# FROM python:3.11.0-buster

# UPDATE APT-GET
RUN apt-get update

# PYODBC DEPENDENCES
RUN apt-get install -y tdsodbc unixodbc-dev
RUN apt install unixodbc-bin -y
RUN apt-get clean -y
ADD odbcinst.ini /etc/odbcinst.ini

# UPGRADE pip3
RUN pip3 install --upgrade pip

# DEPENDECES FOR DOWNLOAD ODBC DRIVER
RUN apt-get install apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update

# INSTALL ODBC DRIVER
RUN ACCEPT_EULA=Y apt-get install msodbcsql17 --assume-yes

# CONFIGURE ENV FOR /bin/bash TO USE MSODBCSQL17
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

WORKDIR /app
COPY ./flaskapp .
EXPOSE 5000
CMD ["python", "app.py"]


# commands to run
# build image
# docker build -t jasontestflaskname .
# run container
# docker run -p 5000:5000 jasontestflaskname


#executor failed running /bin/sh -c ACCEPT_EULA=Y apt-get install msodbcsql17 --assume-yes exit code 100

# or try: https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-2017&tabs=ubuntu18-install%2Cubuntu17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline#17
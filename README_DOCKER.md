# Dagobah Docker Installation Guide




# Step 0. Install docker/mongodb & clone this repository

## 0. Steps for install docker and mongodb will not list in this guide, please refer to offical installation guide. After you installed them, start the service.

## 1. you might need to modify some of the configs listed in `./ssh/config` and `./dagobahd.yml` , including but not limited to:

`./ssh/config` : target server you want to execute command on

```
    HostName
    User
```

`./dagobahd.yml` : dagobah config file

```shell
    Dagobah
        # host and port for the Flask app. set host to 0.0.0.0 to listen on all IPs, default host 127.0.0.1
        host 
        port

        # credentials for single-user auth, default pwd is dagobah
        auth_disabled: False
        password: wTEb)>4287jX

        # choose one of the available backends, default None
        # None: Dagobah will not use a backend to permanently store data, each time you restart your dagobah daemon, your jobs, logs, all the data will be lost, so strongly recommend you to NOT using this option
        # mongo: store results in MongoDB. see the MongoBackend section in this file
        backend: mongo

    Email# config your email server and so on to send emails when jobs execute succeed or fail

    MongoBackend
        # connection details to a mongo databasem default host is localhost
        host: 192.168.179.131
        port: 27017
        db: dagobah
```

## Note:

You can `mount ` the config files to your docker container from your local machine. eg. :

```
ndong@ndong-virtual-machine:~/software/dagobah$ ls
BugList.MD    dagobah       dagobah_v2.tar      Dockerfile     imgs     MAINTAINERS  memory            README.md         scripts    setup.py  tests
CHANGELOG.md  dagobahd.yml  docker-compose.yml  docker-images  LICENSE  MANIFEST.in  README_DOCKER.md  requirements.txt  setup.cfg  ssh

# chmod of mount files
ndong@ndong-virtual-machine:~/software/dagobah$ chmod 777 dagobahd.yml 
ndong@ndong-virtual-machine:~/software/dagobah$ chmod -R 777 ./ssh

# run docker container
ndong@ndong-virtual-machine:~/software/dagobah$ docker run -d -v /home/ndong/software/dagobah/dagobahd.yml:/root/.dagobahd.yml -v /home/ndong/software/dagobah/ssh/config:/root/.ssh/config --name dagobah -p 9000:9000 dagobah:v1
1f41f05c1f0a7d50196d89b1177fcfdd077c5b7de0855f3ac70b267eaae31328

ndong@ndong-virtual-machine:~/software/dagobah$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS                      NAMES
1f41f05c1f0a        dagobah:v1          "dagobahd"               4 seconds ago       Exited (1) 2 seconds ago                              dagobah
0a8155e92c44        mongo:4.0.2         "docker-entrypoint.s…"   3 minutes ago       Up 3 minutes               0.0.0.0:27017->27017/tcp   mongo_4
e581e2f264ff        python:2.7          "bash"                   5 days ago          Exited (0) 2 days ago                                 thirsty_curie
04f4c27a997b        ubuntu:16.04        "bash"                   5 days ago          Exited (0) 2 days ago 
```



# Setp 1. Build docker images using Dockerfile

```shell
ndong@ndong-virtual-machine:~/software/dagobah$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
mongo               4.0.2               e3985c6fb3c8        4 days ago          381MB
ubuntu              16.04               b9e15a5d1e1a        6 days ago          115MB
python              2.7                 4ee4ea2f0113        7 days ago          908MB
mongo               3.4.16              703d9cabbdca        7 days ago          361MB
hello-world         latest              2cb0d9787c4d        2 months ago        1.85kB

ndong@ndong-virtual-machine:~/software/dagobah$ ls
BugList.MD  CHANGELOG.md  dagobah  dagobahd.yml  Dockerfile  imgs  LICENSE  MAINTAINERS  MANIFEST.in  memory  README_DOCKER.md  README.md  requirements.txt  scripts  setup.cfg  setup.py  ssh  tests

ndong@ndong-virtual-machine:~/software/dagobah$ docker build -t dagobah:v1 .
Sending build context to Docker daemon  7.499MB
Step 1/11 : FROM python:2.7
 ---> 4ee4ea2f0113
Step 2/11 : MAINTAINER dong-shuai <599054912@qq.com>
 ---> Running in d53db1cc0ef3
Removing intermediate container d53db1cc0ef3
 ---> acc0b5e305ec
Step 3/11 : ENV v_workdir /dagobah
 ---> Running in fda352429662
Removing intermediate container fda352429662
 ---> e2dde73a00b7
Step 4/11 : RUN mkdir -p ${v_workdir}"/ssh"
 ---> Running in 8ab1f9f9a8b1
Removing intermediate container 8ab1f9f9a8b1
 ---> 003ff21eb3d1
Step 5/11 : COPY ./ssh/* ${v_workdir}"/ssh"
 ---> f3cfe1212534
Step 6/11 : COPY ./dagobahd.yml ./requirements.txt ${v_workdir}"/"
 ---> 97772524f4cc
Step 7/11 : WORKDIR ${v_workdir}
 ---> Running in e3c7675be075
Removing intermediate container e3c7675be075
 ---> 72553b42808a
Step 8/11 : RUN pip install -r ./requirements.txt && pip install git+https://github.com/dong-shuai/dagobah.git
 ---> Running in a46f8663fd07

#lots of outputs

Removing intermediate container a46f8663fd07
 ---> 91201af9abe5
Step 9/11 : RUN mv /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml_backup && cp ${v_workdir}/dagobahd.yml /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml && mkdir -p /root/.ssh && cp ${v_workdir}/ssh/* /root/.ssh/ && chmod 600 /root/.ssh/* && chown root /root/.ssh/* && echo "    IdentityFile /root/.ssh/id_rsa" >> /etc/ssh/ssh_config
 ---> Running in ba423852e073
Removing intermediate container ba423852e073
 ---> c3c228351478
Step 10/11 : EXPOSE 9000
 ---> Running in 3fffb36602f3
Removing intermediate container 3fffb36602f3
 ---> 9d6d5a3855bd
Step 11/11 : CMD ["dagobahd"]
 ---> Running in a6e1274db837
Removing intermediate container a6e1274db837
 ---> 91a20f68a401
Successfully built 91a20f68a401
Successfully tagged dagobah:v1

ndong@ndong-virtual-machine:~/software/dagobah$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
dagobah             v1                  91a20f68a401        2 minutes ago       971MB
mongo               4.0.2               e3985c6fb3c8        4 days ago          381MB
ubuntu              16.04               b9e15a5d1e1a        6 days ago          115MB
python              2.7                 4ee4ea2f0113        7 days ago          908MB
mongo               3.4.16              703d9cabbdca        7 days ago          361MB
hello-world         latest              2cb0d9787c4d        2 months ago        1.85kB
```

# Step 2. SSH Config

## 1. modify config file /root/.ssh/config if needed 

```shell
ndong@ndong-virtual-machine:~/software/dagobah$ docker run -ti dagobah:v1 bash
root@c5f6f36c7547:/dagobah# ls -l
total 12
-rw-rw-r-- 1 root root 3664 Sep 12 07:24 dagobahd.yml
-rw-rw-r-- 1 root root  284 Sep 12 07:49 requirements.txt
drwxr-xr-x 1 root root 4096 Sep 12 07:50 ssh
root@c5f6f36c7547:/dagobah# cat ~/.ssh/config 
Host targrt_db_server
    HostName 192.168.179.131
    Port 22
    User ndong
    IdentityFile /root/.ssh/id_rsa
root@c5f6f36c7547:/dagobah# exit
exit
ndong@ndong-virtual-machine:~/software/dagobah$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS                      NAMES
f66aefdbd33d        dagobah:v1          "bash"                   9 seconds ago       Exited (0) 8 seconds ago                              admiring_ptolemy
b6883c0b0415        mongo:4.0.2         "docker-entrypoint.s…"   41 hours ago        Up 7 hours                 0.0.0.0:27017->27017/tcp   mongo4.0.2
e581e2f264ff        python:2.7          "bash"                   4 days ago          Exited (0) 46 hours ago                               thirsty_curie
04f4c27a997b        ubuntu:16.04        "bash"                   4 days ago          Exited (0) 2 days ago                                 eager_noyce
ndong@ndong-virtual-machine:~/software/dagobah$ docker rm f66aefdbd33d
f66aefdbd33d

# we don't have vim installed inside the dagobah docker container, so 
# 1. Modify locally and then upload to docker container, you can using commend `docker cp localfile  container:container_path` 
# 2. Mount local config file to container, refer to Step1
```

### File content
```shell
Host targrt_db_server              #alias name
    HostName 192.168.179.131       #target server, eg. 192.168.179.131
    Port 22                        #target server port
    User ndong                     #target server user name
    IdentityFile /root/.ssh/id_rsa #local(this dagobah container) privite key
    StrictHostKeyChecking no       #lowest security level, used in intranet and for test only, NOT in PROD env
    UserKnownHostsFile=/dev/null
```

### Purpose:
Create a config named `targrt_db_server`, Using user `root` in the `dagobah container` to ssh to user `ndong` in remote target server to execute commands.



## 2.  Generate SSH keys inside Dagobah docker container

### 0). Start docker container
```shell
ndong@ndong-virtual-machine:~/software/dagobah$ docker run -d -v /home/ndong/software/dagobah/dagobahd.yml:/root/.dagobahd.yml -v /home/ndong/software/dagobah/ssh/config:/root/.ssh/config --name dagobah -p 9000:9000 dagobah:v1
f4625ee52359b9fdacd95cafc19a1b6a2d7ea76fbe4b6b468faeb26962d29145
ndong@ndong-virtual-machine:~/software/dagobah$ docker ps 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                      NAMES
f4625ee52359        dagobah:v1          "dagobahd"               6 seconds ago       Up 4 seconds        0.0.0.0:9000->9000/tcp     dagobah
b6883c0b0415        mongo:4.0.2         "docker-entrypoint.s…"   41 hours ago        Up 7 hours          0.0.0.0:27017->27017/tcp   mongo4.0.2
```


### 1). You need to generate ssh keys as root user in docker container first (or you can generate somewhere else, and copy them into docker container /root/.ssh/)

```shell
ndong@ndong-virtual-machine:~/software/dagobah$ docker exec -ti f4625ee52359 bash
root@f4625ee52359:/dagobah# 
root@f4625ee52359:/dagobah# cd ~/.ssh
root@f4625ee52359:/dagobah# ls
config

root@f4625ee52359:~/.ssh# ssh-keygen -t rsa -C “docker-dagobah”
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:EmEyo5rqR3DK71z7VGy983ls1JVAMnUJEzVIX6YIrrg “docker-dagobah”
The key's randomart image is:
+---[RSA 2048]----+
|    + o   .o+B=++|
|   . = . . .o+++o|
|  .   .   . . o..|
| + .   o...    ..|
|+ +   o S+ .    o|
|.o .   oo   .  ..|
|. o  .E.   o  o  |
|. .o. o     o .+ |
| .oo ...     oo  |
+----[SHA256]-----+

root@f4625ee52359:/dagobah# ls
config	id_rsa	id_rsa.pub
```

### 2). Using commend `ssh-copy-id` , copy your public key to target server(add into Users'  ~/.ssh/authorized_keys file, eg. /home/ndong/.ssh/authorized_keys), or some other way you want.

```shell
root@f4625ee52359:~/.ssh# chmod 600 ~/.ssh/config 
root@f4625ee52359:~/.ssh# chown root  ~/.ssh/config

root@f4625ee52359:~/.ssh# ssh-copy-id ndong@192.168.179.131
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ndong@192.168.179.131's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ndong@192.168.179.131'"
and check to make sure that only the key(s) you wanted were added.
```

### 3). you need to manually login to the target server for the first time，requires target server user's password. Main purpose is to add remote server's `ECDSA key fingerprint` into your local docker's known hosts(under /root/.ssh/known_hosts)

```shell
root@f4625ee52359:~/.ssh# ssh ndong@192.168.179.131
The authenticity of host '192.168.179.131 (192.168.179.131)' can't be established.
ECDSA key fingerprint is SHA256:D7P7D3V6eOhbqo8fHUgj/jgIff8vYbkj79vcjlXO8kk.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.179.131' (ECDSA) to the list of known hosts.
ndong@192.168.179.131's password: 
Welcome to Ubuntu 16.04.2 LTS (GNU/Linux 4.8.0-36-generic x86_64)
Last login: Wed Sep 12 10:08:20 2018 from 192.168.179.1
ndong@ndong-virtual-machine:~$ ls ~/.ssh/
authorized_keys  id_rsa  id_rsa.pub  log
ndong@ndong-virtual-machine:~$ exit
exit
Connection to 192.168.179.131 closed.
root@f4625ee52359:~/.ssh#
root@f4625ee52359:~/.ssh# ls
config	id_rsa	id_rsa.pub  known_hosts
root@f4625ee52359:~/.ssh# exit
exit
ndong@ndong-virtual-machine:~/software/dagobah$
```

### 4). Restart docker and now you are ready to using Remote Target Hosts in Dagobah!
```shell
ndong@ndong-virtual-machine:~/software/dagobah$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                    PORTS                      NAMES
f4625ee52359        dagobah:v1          "dagobahd"               9 minutes ago       Up 9 minutes              0.0.0.0:9000->9000/tcp     dagobah
b6883c0b0415        mongo:4.0.2         "docker-entrypoint.s…"   41 hours ago        Up 7 hours                0.0.0.0:27017->27017/tcp   mongo4.0.2
e581e2f264ff        python:2.7          "bash"                   4 days ago          Exited (0) 47 hours ago                              thirsty_curie
04f4c27a997b        ubuntu:16.04        "bash"                   4 days ago          Exited (0) 2 days ago                                eager_noyce
ndong@ndong-virtual-machine:~/software/dagobah$ docker restart f4625ee52359
f4625ee52359
ndong@ndong-virtual-machine:~/software/dagobah$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                    PORTS                      NAMES
f4625ee52359        dagobah:v1          "dagobahd"               9 minutes ago       Up 6 seconds              0.0.0.0:9000->9000/tcp     dagobah
b6883c0b0415        mongo:4.0.2         "docker-entrypoint.s…"   41 hours ago        Up 7 hours                0.0.0.0:27017->27017/tcp   mongo4.0.2
e581e2f264ff        python:2.7          "bash"                   4 days ago          Exited (0) 47 hours ago                              thirsty_curie
04f4c27a997b        ubuntu:16.04        "bash"                   4 days ago          Exited (0) 2 days ago                                eager_noyce
ndong@ndong-virtual-machine:~/software/dagobah$ 

```

ps: Of course your target server should have openssh-server installed and properly configured to allow ssh login.



# Step 3. Docker Image Offline Deploy

## 1. Build your image on a network connected server, refer guides above

Some times, you want to deploy a configured container rather than an images, you can `commit` your container to an image, then deploy it.

```shell
ndong@ndong-virtual-machine:~/software/dagobah$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                      NAMES
f4625ee52359        dagobah:v1          "dagobahd"               About an hour ago   Up 35 minutes       0.0.0.0:9000->9000/tcp     dagobah
b6883c0b0415        mongo:4.0.2         "docker-entrypoint.s…"   42 hours ago        Up 8 hours          0.0.0.0:27017->27017/tcp   mongo4.0.2

ndong@ndong-virtual-machine:~/software/dagobah$ docker commit f4625ee52359 dagobah:v2
sha256:b9a3569912028dc5cb99e9f7d50a9ceebf58a296c3159fff411fb97ab4377db1

ndong@ndong-virtual-machine:~/software/dagobah$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
dagobah             v2                  b9a356991202        9 seconds ago       973MB
dagobah             v1                  91a20f68a401        About an hour ago   971MB
mongo               4.0.2               e3985c6fb3c8        4 days ago          381MB
ubuntu              16.04               b9e15a5d1e1a        6 days ago          115MB
python              2.7                 4ee4ea2f0113        7 days ago          908MB
mongo               3.4.16              703d9cabbdca        7 days ago          361MB
hello-world         latest              2cb0d9787c4d        2 months ago        1.85kB

```



## 2.  Save your docker image as a file

```shell
ndong@ndong-virtual-machine:~/software/dagobah$ docker save -o dagobah_v2.tar dagobah:v2

ndong@ndong-virtual-machine:~/software/dagobah$ ls
BugList.MD    dagobah       dagobah_v2.tar  imgs     MAINTAINERS  memory            README.md         scripts    setup.py  tests
CHANGELOG.md  dagobahd.yml  Dockerfile      LICENSE  MANIFEST.in  README_DOCKER.md  requirements.txt  setup.cfg  ssh

ndong@ndong-virtual-machine:~/software/dagobah$ du -sh dagobah_v2.tar 
956M	dagobah_v2.tar

```



## 3. Copy the saved file to your remote server, and load the file back to docker image

```shell
[root@localhost software]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
mongo               latest              d2fc5a3281a1        6 days ago          380.2 MB
ubuntu              latest              cef111cd4bae        6 days ago          84.11 MB
python              2.7                 f1e0d5b6b737        7 days ago          907.6 MB
python              latest              3cd1a8bc2f04        7 days ago          922.4 MB
hjd48/redhat        latest              ab1ad8757648        3 years ago         414.2 MB
[root@localhost software]# ls
dagobah  dagobah_v2.tar  docker-compose-Linux-x86_64_1.5.2  openssl-OpenSSL_1_0_1q.tar.gz  pip-9.0.3  pip-9.0.3.tar.gz  Python-2.7.13  Python-2.7.13.tgz  setuptools-0.6c11-py2.6.egg
[root@localhost software]# docker load --input dagobah_v2.tar 
[root@localhost software]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
dagobah             v2                  1add4356a08a        16 minutes ago      972.9 MB
mongo               latest              d2fc5a3281a1        6 days ago          380.2 MB
ubuntu              latest              cef111cd4bae        6 days ago          84.11 MB
python              2.7                 f1e0d5b6b737        7 days ago          907.6 MB
python              latest              3cd1a8bc2f04        7 days ago          922.4 MB
hjd48/redhat        latest              ab1ad8757648        3 years ago         414.2 MB
[root@localhost software]# 
```

## 4. Config what you need to config, install what you need to install, and enjoy you dagobah docker container.

Like install mongodb, config mongodb connection info.

Like  ssh key generate/ ssh config...

## Note:

You can always `MOUNT ` the config files to your docker container from your local machine.






# Step N: docker-compose

## 1. Install docker-compose
## 2. Pull mongo
```shell
ndong@ndong-virtual-machine:~/software/dagobah #docker pull mongo:4.0.2
```
## 3. Run
```shell

ndong@ndong-virtual-machine:~/software/dagobah$ ls
BugList.MD    dagobah       dagobah_v2.tar      Dockerfile     imgs     MAINTAINERS  memory            README.md         scripts    setup.py  tests
CHANGELOG.md  dagobahd.yml  docker-compose.yml  docker-images  LICENSE  MANIFEST.in  README_DOCKER.md  requirements.txt  setup.cfg  ssh

ndong@ndong-virtual-machine:~/software/dagobah$ cat docker-compose.yml
version: '3'
services:
    dagobah:
        build: .
        #image: dongshuai/dagobah
        links:
         - mongo:mongodb
        ports:
         - 9000:9000
        volumes:
        - ./dagobahd.yml:/root/.dagobahd.yml
        - ./ssh/config:/root/.ssh/config
        depends_on:
         - mongo
        container_name: dagobah_container

    mongo:
        image: "mongo:4.0.2"
        volumes:
        - /data/mongodata:/data/db
        container_name: mongodb_4.0.2_container
        
ndong@ndong-virtual-machine:~/software/dagobah$ mkdir -p /data/mongodata

ndong@ndong-virtual-machine:~/software/dagobah$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
mongo               4.0.2               e3985c6fb3c8        5 days ago          381MB
ubuntu              16.04               b9e15a5d1e1a        7 days ago          115MB
python              2.7                 4ee4ea2f0113        7 days ago          908MB
mongo               3.4.16              703d9cabbdca        8 days ago          361MB
hello-world         latest              2cb0d9787c4d        2 months ago        1.85kB

ndong@ndong-virtual-machine:~/software/dagobah$ docker-compose build
mongo uses an image, skipping
Building dagobah
Step 1/11 : FROM python:2.7
 ---> 4ee4ea2f0113
Step 2/11 : MAINTAINER dong-shuai <599054912@qq.com>
 ---> Running in 26d75f85729e
Removing intermediate container 26d75f85729e
 ---> 313bfee8c987
Step 3/11 : ENV v_workdir /dagobah
 ---> Running in e8980d2c9bab
Removing intermediate container e8980d2c9bab
 ---> 187449c01d56
Step 4/11 : RUN mkdir -p ${v_workdir}"/ssh"
 ---> Running in 0b38c1356864
Removing intermediate container 0b38c1356864
 ---> 11e830d60cb5
Step 5/11 : COPY ./ssh/* ${v_workdir}"/ssh"
 ---> ddb798916ee1
Step 6/11 : COPY ./dagobahd.yml ./requirements.txt ${v_workdir}"/"
 ---> e3dd6dca8975
Step 7/11 : WORKDIR ${v_workdir}
 ---> Running in 52c2d54f2acc
Removing intermediate container 52c2d54f2acc
 ---> e957731102b6
Step 8/11 : RUN pip install -r ./requirements.txt && pip install git+https://github.com/dong-shuai/dagobah.git
 ---> Running in d7759e9d8f12
# a lots of outputs
Successfully built dagobah
Installing collected packages: dagobah
Successfully installed dagobah-0.3.4
Removing intermediate container d7759e9d8f12
 ---> 68df8b863779
Step 9/11 : RUN mv /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml_backup && cp ${v_workdir}/dagobahd.yml /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml && mkdir -p /root/.ssh && cp ${v_workdir}/ssh/* /root/.ssh/ && chmod 600 /root/.ssh/* && chown root /root/.ssh/* && echo "    IdentityFile /root/.ssh/id_rsa" >> /etc/ssh/ssh_config
 ---> Running in 211007c751ce
Removing intermediate container 211007c751ce
 ---> 2c690134d5d8
Step 10/11 : EXPOSE 9000
 ---> Running in b1dece715b6a
Removing intermediate container b1dece715b6a
 ---> 4640b7d58cc7
Step 11/11 : CMD ["dagobahd"]
 ---> Running in 25db0c72c657
Removing intermediate container 25db0c72c657
 ---> 633b52942fde
Successfully built 633b52942fde
Successfully tagged dagobah_dagobah:latest

ndong@ndong-virtual-machine:~/software/dagobah$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
dagobah_dagobah     latest              633b52942fde        3 minutes ago       968MB
mongo               4.0.2               e3985c6fb3c8        5 days ago          381MB
ubuntu              16.04               b9e15a5d1e1a        7 days ago          115MB
python              2.7                 4ee4ea2f0113        7 days ago          908MB
mongo               3.4.16              703d9cabbdca        8 days ago          361MB
hello-world         latest              2cb0d9787c4d        2 months ago        1.85kB

ndong@ndong-virtual-machine:~/software/dagobah$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                  PORTS               NAMES
e581e2f264ff        python:2.7          "bash"              5 days ago          Exited (0) 2 days ago                       thirsty_curie
04f4c27a997b        ubuntu:16.04        "bash"              5 days ago          Exited (0) 2 days ago                       eager_noyce
ndong@ndong-virtual-machine:~/software/dagobah$ docker-compose up -d
Creating network "dagobah_default" with the default driver
Creating mongodb_4.0.2_container ... done
Creating dagobah_container       ... done
ndong@ndong-virtual-machine:~/software/dagobah$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                    NAMES
1f0a7df1ba1a        dagobah_dagobah     "dagobahd"               11 seconds ago      Up 11 seconds           0.0.0.0:9000->9000/tcp   dagobah_container
49310bdc4cd9        mongo:4.0.2         "docker-entrypoint.s…"   12 seconds ago      Up 11 seconds           27017/tcp                mongodb_4.0.2_container
e581e2f264ff        python:2.7          "bash"                   5 days ago          Exited (0) 2 days ago                            thirsty_curie
04f4c27a997b        ubuntu:16.04        "bash"                   5 days ago          Exited (0) 2 days ago                            eager_noyce

ndong@ndong-virtual-machine:~/software/dagobah$ ll /data/mongodata
总用量 212
drwxr-xr-x 4   999 ndong   4096 9月  13 11:13 ./
drwxr-xr-x 3 ndong ndong   4096 9月  13 11:00 ../
-rw------- 1   999 docker 16384 9月  13 11:13 collection-0--7604890380586699482.wt
-rw------- 1   999 docker 16384 9月  13 11:13 collection-10--7604890380586699482.wt
-rw------- 1   999 docker 16384 9月  13 11:13 collection-2--7604890380586699482.wt
-rw------- 1   999 docker  4096 9月  13 11:12 collection-4--7604890380586699482.wt
-rw------- 1   999 docker  4096 9月  13 11:12 collection-7--7604890380586699482.wt
drwx------ 2   999 docker  4096 9月  13 11:13 diagnostic.data/
-rw------- 1   999 docker 16384 9月  13 11:13 index-11--7604890380586699482.wt
-rw------- 1   999 docker 16384 9月  13 11:13 index-1--7604890380586699482.wt
-rw------- 1   999 docker 16384 9月  13 11:13 index-3--7604890380586699482.wt
-rw------- 1   999 docker  4096 9月  13 11:12 index-5--7604890380586699482.wt
-rw------- 1   999 docker  4096 9月  13 11:13 index-6--7604890380586699482.wt
-rw------- 1   999 docker  4096 9月  13 11:12 index-8--7604890380586699482.wt
-rw------- 1   999 docker  4096 9月  13 11:12 index-9--7604890380586699482.wt
drwx------ 2   999 docker  4096 9月  13 11:12 journal/
-rw------- 1   999 docker 16384 9月  13 11:13 _mdb_catalog.wt
-rw------- 1   999 docker     2 9月  13 11:12 mongod.lock
-rw------- 1   999 docker  4096 9月  13 11:12 sizeStorer.wt
-rw------- 1   999 docker   114 9月  13 11:12 storage.bson
-rw------- 1   999 docker    45 9月  13 11:12 WiredTiger
-rw------- 1   999 docker  4096 9月  13 11:12 WiredTigerLAS.wt
-rw------- 1   999 docker    21 9月  13 11:12 WiredTiger.lock
-rw------- 1   999 docker  1057 9月  13 11:13 WiredTiger.turtle
-rw------- 1   999 docker 32768 9月  13 11:13 WiredTiger.wt
ndong@ndong-virtual-machine:~/software/dagobah$ 

```
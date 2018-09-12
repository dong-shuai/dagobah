# need to build under folder dagobah
FROM python:2.7

MAINTAINER dong-shuai <599054912@qq.com>

ENV v_workdir /dagobah
RUN mkdir -p ${v_workdir}"/ssh"
COPY ./ssh/* ${v_workdir}"/ssh"
COPY ./dagobahd.yml ./requirements.txt ${v_workdir}"/"
WORKDIR ${v_workdir}

RUN pip install -r ./requirements.txt && pip install git+https://github.com/dong-shuai/dagobah.git

RUN mv /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml_backup && cp ${v_workdir}/dagobahd.yml /usr/local/lib/python2.7/site-packages/dagobah/daemon/dagobahd.yml && mkdir -p /root/.ssh && cp ${v_workdir}/ssh/* /root/.ssh/ && chmod 600 /root/.ssh/* && chown root /root/.ssh/* && echo "    IdentityFile /root/.ssh/id_rsa" >> /etc/ssh/ssh_config

EXPOSE 9000

CMD ["dagobahd"]

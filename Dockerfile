FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y curl apt-transport-https tzdata

ENV TZ=Asia/Kolkata
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir /scripts

COPY --chmod=0755 your_script.sh /scripts/your_script.sh

RUN touch /var/log/your_script.log

CMD ["bash", "/scripts/your_script.sh"]

RUN apt-get update && \
    apt-get install -y cron curl apt-transport-https tzdata
    


ENV TZ=Asia/Kolkata
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata


RUN mkdir /scripts


COPY --chmod=0755 your_script.sh /scripts/your_script.sh
COPY crontab /etc/cron.d/my-cron-job

RUN chmod 0644 /etc/cron.d/my-cron-job


RUN crontab /etc/cron.d/my-cron-job


RUN touch /var/log/cron.log

CMD ["bash", "-c", "cron && tail -f /var/log/cron.log"]
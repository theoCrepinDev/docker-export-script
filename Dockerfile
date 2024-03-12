FROM oven/bun:1.0.26

RUN apt-get update && \
    apt-get install -y wget gnupg git openssh-client && \
    echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-client-16 cron

VOLUME /dumps

WORKDIR /app

COPY export_data.sh .
RUN mkdir /root/.ssh && chmod -R 700 /root/.ssh
COPY keys /root/.ssh/id_rsa
RUN chmod 0400 /root/.ssh/id_rsa && echo "StrictHostKeyChecking no" > /root/.ssh/config
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts


CMD ["/bin/bash", "./export_data.sh"]
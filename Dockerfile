FROM openjdk:11-bullseye as builder

RUN apt-get update && \
    apt-get install apt-transport-https curl gnupg -yqq && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import && \
    chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg && \
    apt-get update && \
    apt-get install sbt

COPY . cromwell/
RUN cd cromwell && sbt assembly

FROM openjdk:21-buster
RUN mkdir /opt/cromwell /root/.docker && \
  apt-get update && apt-get install -y docker.io amazon-ecr-credential-helper slurm-client munge && \
  printf '{\n  "credsStore": "ecr-login"\n}\n' > /root/.docker/config.json
RUN wget -O /opt/dd-java-agent.jar https://dtdg.co/latest-java-tracer
COPY --from=builder /cromwell/server/target/scala-2.13/cromwell-88-*-SNAP.jar /opt/cromwell/cromwell.jar
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

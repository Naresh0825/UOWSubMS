# Use the specific WildFly version requested
FROM quay.io/wildfly/wildfly:31.0.1.Final-jdk17

# Set environment variables for convenience
ENV JBOSS_HOME /opt/jboss/wildfly

# Valitag OMS
COPY target/UOWSubMS.war ${JBOSS_HOME}/standalone/deployments/UOWSubMS.war

# Setup wildfly standalone instance
RUN ${JBOSS_HOME}/bin/add-user.sh admin admin --silent
COPY docker/setup-wildfly.cli ${JBOSS_HOME}/bin/

# Generate the self-signed certificate inside the container
RUN keytool -genkeypair -alias localhost -keyalg RSA -keysize 2048 \
    -validity 365 -keystore ${JBOSS_HOME}/standalone/configuration/application.keystore \
    -storepass password -keypass password \
    -dname "CN=localhost, OU=Dev, O=Unitech, L=Sydney, ST=NSW, C=AU" \
    -ext "SAN=dns:localhost,ip:127.0.0.1"

EXPOSE 80 443 8787 9990

CMD ${JBOSS_HOME}/bin/jboss-cli.sh --file=${JBOSS_HOME}/bin/setup-wildfly.cli && \
    ${JBOSS_HOME}/bin/standalone.sh \
      -b 0.0.0.0 \
      -bmanagement 0.0.0.0 \
      --debug "*:8787" \
      -Dwildfly.elytron.oidc.disable.typ.claim.validation=true

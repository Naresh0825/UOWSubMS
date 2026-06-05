# Use the specific WildFly version requested
FROM quay.io/wildfly/wildfly:31.0.1.Final-jdk17

# Set environment variables for convenience
ENV JBOSS_HOME /opt/jboss/wildfly

# Deploy the application
COPY docker/UOWSubMS.war ${JBOSS_HOME}/standalone/deployments/UOWSubMS.war

# Create admin user
RUN ${JBOSS_HOME}/bin/add-user.sh admin admin --silent

# Overwrite the default standalone.xml with your custom configuration
COPY docker/standalone.xml ${JBOSS_HOME}/standalone/configuration/standalone.xml

# Generate the self-signed certificate inside the container for HTTPS
RUN keytool -genkeypair -alias localhost -keyalg RSA -keysize 2048 \
    -validity 365 -keystore ${JBOSS_HOME}/standalone/configuration/application.keystore \
    -storepass password -keypass password \
    -dname "CN=localhost, OU=Dev, O=Unitech, L=Sydney, ST=NSW, C=AU" \
    -ext "SAN=dns:localhost,ip:127.0.0.1"

# Expose necessary ports (80 for HTTP, 443 for HTTPS, 8787 for Debug, 9990 for Admin)
EXPOSE 80 443 8787 9990

# Start WildFly bound to 0.0.0.0 (Crucial for Render/Docker routing)
CMD ${JBOSS_HOME}/bin/standalone.sh \
      -b 0.0.0.0 \
      -bmanagement 0.0.0.0 \
      --debug "*:8787" \
      -Dwildfly.elytron.oidc.disable.typ.claim.validation=true
FROM quay.io/keycloak/keycloak:latest as builder
# Necessary to let us use PostgreSQL
ENV OPERATOR_KEYCLOAK_IMAGE=quay.io/keycloak/keycloak:latest
# Set Render's assigned HTTP port (8443)
ENV PROXY_ADDRESS_FORWARDING=true
ENV KC_DB_USERNAME=$DB_USERNAME
ENV KC_DB_PASSWORD=$DB_PASSWORD
ENV KC_DB_URL_PROPERTIES='?'
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME=https://keycloak-service-do14.onrender.com
ENV KC_HOSTNAME_ADMIN=https://keycloak-service-do14.onrender.com
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8443
ENV KC_HTTPS_PORT=8444
ENV KC_LOG_LEVEL=INFO
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_PROXY=passthrough
ENV KC_PROXY_HEADERS=xforwarded
ENV KEYCLOAK_ADMIN=$ADMIN
ENV KEYCLOAK_ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV KB_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://${DB_URL}:${DB_PORT}/${DB_DATABASE}
# Database may seem redundant but it is not
RUN /opt/keycloak/bin/kc.sh build --db=postgres

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Necessary to let us use PostgreSQL
ENV OPERATOR_KEYCLOAK_IMAGE=quay.io/keycloak/keycloak:latest

# Set port 8443 to PORT environment variable in Render
ENV PROXY_ADDRESS_FORWARDING=true
ENV KC_DB_USERNAME=$DB_USERNAME
ENV KC_DB_PASSWORD=$DB_PASSWORD
ENV KC_DB_URL_PROPERTIES='?'
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME=https://keycloak-service-do14.onrender.com
ENV KC_HOSTNAME_ADMIN=https://keycloak-service-do14.onrender.com
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8443
ENV KC_HTTPS_PORT=8444
ENV KC_LOG_LEVEL=INFO
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_PROXY=passthrough
ENV KC_PROXY_HEADERS=xforwarded
ENV KEYCLOAK_ADMIN=$ADMIN
ENV KEYCLOAK_ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV KB_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://${DB_URL}:${DB_PORT}/${DB_DATABASE}

EXPOSE 8443
EXPOSE 8444

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
# Even though we build, using --optimized disallows PostgreSQL databases,
# so we need this workaround https://github.com/keycloak/keycloak/issues/15898
# In other words, don't add --optimized here
CMD ["start", "--db=postgres"]

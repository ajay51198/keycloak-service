FROM quay.io/keycloak/keycloak:latest AS builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure database vendor
ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://dpg-d0l2ii9r0fns7392k780-a/keycloak_db_oga2
ENV KC_DB_USERNAME=tbt_dev_user
ENV KC_DB_PASSWORD=o96Wz4Yh88uoMVLbFCiV8zLMkmwEQJQs
ENV KC_HTTP_PORT=8080
ENV PORT=8080
# Configure Keycloak hostname
ENV KC_HOSTNAME=https://keycloak-service-do14.onrender.com

# Admin user setup
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

WORKDIR /opt/keycloak

# Generate Keycloak self-signed certificate (for demonstration purposes only)
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 \
    -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" \
    -keystore conf/server.keystore

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Cache configuration
ENV KC_CACHE=local

# Port binding - Uses Render's dynamically assigned port
EXPOSE 8080
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--http-port=8080", "--http-host=0.0.0.0"]

# #####################################################################
# This is a rancher template for generating `docker-compose` files.
# Refer to Rancher docs on syntax:
# - https://rancher.com/docs/rancher/v1.6/en/cli/variable-interpolation/#templating
# - https://docs.docker.com/compose/compose-file/compose-file-v2/
# #####################################################################
version: '2'

volumes:
  redis_data:

# +++++++++++++++++++++++
# BEGIN SERVICES
# +++++++++++++++++++++++
services:

  # ************************************
  # SERVICE
  # - redis
  # ************************************
  redis:
    image: redis
    ports:
      - '6379:6379'
    volumes:
      - redis_data:/var/lib/redis

  # ************************************
  # SERVICE
  # - primary application
  # ************************************
  commandapi:

    # -----------------------------------
    # Image
    # - support private registry and custom image
    # -----------------------------------
{{- if (.Values.CUSTOM_REGISTRY) }}
{{-   if (.Values.CUSTOM_IMAGE) }}
    image: "${CUSTOM_REGISTRY}/${CUSTOM_IMAGE}"
{{-   else }}
    image: "${CUSTOM_REGISTRY}/${MAIN_IMAGE}"
{{-   end }}
{{- else }}
{{-   if (.Values.CUSTOM_IMAGE) }}
    image: ${CUSTOM_IMAGE}
{{-   else }}
    image: ${MAIN_IMAGE}
{{-   end }}
{{- end }}

    # -----------------------------------
    # External link
    # - link to db server
    # -----------------------------------
    external_links:
      - ${db_service}:db

    links:
      - redis

    depends_on:
      - redis

    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      USERMAN_API: "${TPMAN_URL}"
      DB_HOST: db
      DB_PORT: 3306
      DB_USER: "${dbuser}"
      DB_PASS: "${dbpassword}"
      DB_NAME: "${dbname}"
      DB_DIALECT: mariadb

      KEYCLOAK_BASE_URL: "${keycloakBaseUrl}"
      NODE_ENV: production
      REDIS_HOST: 'redis'

    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.tpp.role: "{{ .Stack.Name }}/service"
      io.tpp.portal: spread
      io.rancher.scheduler.affinity:container_label_soft_ne: io.tpp.portal=spread
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}

    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{- if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{- end }}
    cpu_shares: ${docker_cpu_weight_limit}

    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
    memswap_limit: "${docker_memory_limit}m"
{{- end }}

    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{- if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{- end }}
    cpu_shares: ${docker_cpu_weight_limit}

    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
    memswap_limit: "${docker_memory_limit}m"
{{- end }}

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

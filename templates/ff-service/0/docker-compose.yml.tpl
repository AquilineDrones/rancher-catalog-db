# #####################################################################
# This is a rancher template for generating `docker-compose` files.
# Refer to Rancher docs on syntax:
# - https://rancher.com/docs/rancher/v1.6/en/cli/variable-interpolation/#templating
# - https://docs.docker.com/compose/compose-file/compose-file-v2/
# #####################################################################
version: '2'

# +++++++++++++++++++++++
# BEGIN SERVICES
# +++++++++++++++++++++++
services:
  # ************************************
  # SERVICE
  # - primary application
  # ************************************
  hlsService:

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

    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      USERMAN_API: "${TPMAN_URL}"
      DB_HOST: db
      DB_USER: "${dbuser}"
      DB_PASS: "${dbpassword}"
      DB_NAME: "${dbname}"
      DB_DIALECT: mariadb

{{- if eq .Values.DEBUG_MODE "true" }}
      TPP_LOG_LEVEL: 1
      TPP_DBGMODE: "true"
      APP_ENV: "development"
{{- end }}

    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.RAW_VIDEO_VOLUME) }}
      - ${RAW_VIDEO_VOLUME}:/app/storage/raw:ro
{{-   else }}
      - /app/storage/raw
{{- end }}

    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.tpp.role: "{{ .Stack.Name }}/portal"
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

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
  tppd:
    # -----------------------------------
    # Image
    # - support private registry and custom image
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
{{-   if (.Values.tppd_image_custom) }}
    image: "${docker_registry_name}/${tppd_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${tppd_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.tppd_image_custom) }}
    image: ${tppd_image_custom}
{{-   else }}
    image: ${tppd_image}
{{-   end }}
{{- end }}
    # -----------------------------------
    # External link
    # - link to sso server
    # -----------------------------------
    external_links:
      - ${sso_service}:sso
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      TPMAN_APP_URL: "${tpp_app_url}"
      TPMAN_OIDC_URL: "${tpp_oidc_url}"
      TPMAN_OIDC_ID: "${tpp_client_id}"
      TPMAN_OIDC_SECRET: "${tpp_client_secret}"
{{- if (.Values.tpp_cors) }}
      TPMAN_CORS: "${tpp_cors}"
{{-   if ne .Values.tpp_cors "*" }}
      TPMAN_CORS_CREDENTIALS: "true"
{{-   end }}
{{- end }}
      TPMAN_CLUSTER_SECRET: "${tpp_cluster_secret}"
      TPMAN_OIDC_ADMIN_USER: "${tpp_admin_user}"
      TPMAN_OIDC_ADMIN_SECRET: "${tpp_admin_secret}"
{{- if eq .Values.debug_mode "true" }}
      TPMAN_LOG_LEVEL: 1
      TPMAN_DBGMODE: "true"
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.tppd.role: "{{ .Stack.Name }}/daemon"
      io.tppd.daemon: spread
      io.rancher.scheduler.affinity:container_label_soft_ne: io.tppd.daemon=spread
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_data:/opt/tppd/data
{{- else }}
      - /opt/tppd/data
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

# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++

{{- if (.Values.datavolume_name) }}
volumes:
  # -----------------------------------
  # Data volume
  # -----------------------------------
  {{.Values.datavolume_name}}_data:
{{-   if eq .Values.volume_exists "true" }}
    external: true
{{-   end }}
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-     if eq .Values.volume_exists "false" }}
{{-       if (.Values.storage_driver_nfsopts_host) }}
    driver_opts:
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-         if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-         else }}
      onRemove: purge
{{-         end }}
{{-       end }}
{{-     end }}
{{-   else }}
    driver: local
{{-   end }}
{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

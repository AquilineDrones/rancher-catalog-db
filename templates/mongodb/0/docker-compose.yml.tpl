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
  tpweb:
    # -----------------------------------
    # Image
    # - support private registry and custom image
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
{{-   if (.Values.tpweb_image_custom) }}
    image: "${docker_registry_name}/${tpweb_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${tpweb_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.tpweb_image_custom) }}
    image: ${tpweb_image_custom}
{{-   else }}
    image: ${tpweb_image}
{{-   end }}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      TPP_CDN_BASEURL: "${cdn_baseurl}"
      TPP_FQDN: "${tppd_fqdn}"
{{- if eq .Values.debug_mode "true" }}
      TPP_LOG_LEVEL: 1
      TPP_DBGMODE: "true"
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

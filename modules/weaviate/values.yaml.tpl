persistence:
  enabled: true
  size: "${storage_size}"

env:
  DEFAULT_VECTORIZER_MODULE: "${vectorizer_module}"
  ENABLE_MODULES: "${enable_modules}"

service:
  type: ClusterIP

grpcService:
  type: ClusterIP

authentication:
  anonymous_access:
    enabled: true

logLevel: info

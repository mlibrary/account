(import 'ksonnet-util/kausal.libsonnet') +
(import './config.libsonnet') +
{
  local deploy = $.apps.v1.deployment,
  local container = $.core.v1.container,
  local port = $.core.v1.containerPort,
  local ingress = $.extensions.v1beta1.ingress,

  local config = $._config.patron_account,
  local images = $._images.patron_account,

  patron_account: {
    web: {
      deployment: deploy.new(
        name=config.web.name,
        replicas=1,
        containers=[
          container.new(config.web.name, images.web)
          + container.withPorts(
            [port.new('ui', config.web.port)]
          ) + container.withEnv([{
            name: 'ALMA_API_HOST',
            value: 'https://api-na.hosted.exlibrisgroup.com',
          }, {
            name: 'ALMA_API_KEY',
            valueFrom: {
              secretKeyRef: {
                name: 'credentials',
                key: 'ALMA_API_KEY',
              },
            },
          }]),
        ]
      ),

      service: $.util.serviceFor(self.deployment),

      ingress: ingress.new() + ingress.mixin.metadata.withName(config.web.name)
               + ingress.mixin.metadata.withAnnotations({
                 'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
               }) + ingress.mixin.spec.withRules({
        host: config.web.host,
        http: { paths: [{
          path: '/',
          backend: {
            serviceName: config.web.name,
            servicePort: config.web.port,
          },
        }] },
      }) + ingress.mixin.spec.withTls({
        secretName: '%s-tls' % config.web.name,
        hosts: [config.web.host],
      }),
    },
  },
}

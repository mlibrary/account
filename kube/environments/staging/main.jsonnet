{
  _config+:: {
    patron_account: {
      web: {
        name: 'web',
        port: 4567,
        host: 'staging.patron-account.kubernetes.lib.umich.edu',
      },
    },
  },

  _images+:: {
    patron_account: {
      web: 'mlibrary/patron-account-unstable:latest',
    },
  },
} +
(import 'ksonnet-util/kausal.libsonnet') +
(import 'patron-account/production-config.libsonnet') +
(import 'patron-account/patron-account.libsonnet')

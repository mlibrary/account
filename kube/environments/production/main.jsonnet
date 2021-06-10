{
  _config+:: {
    patron_account: {
      web: {
        name: 'web',
        port: 4567,
        host: 'account.lib.umich.edu',
      },
    },
  },

  _images+:: {
    patron_account: {
      web: 'ghcr.io/mlibrary/patron_account:latest',
    },
  },
} +
(import 'ksonnet-util/kausal.libsonnet') +
(import 'patron-account/production-config.libsonnet') +
(import 'patron-account/patron-account.libsonnet')

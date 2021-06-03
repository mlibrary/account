{
  _config+:: {
    patron_account: {
      web: {
        name: 'web',
        port: 4567,
        host: 'testing.patron-account.kubernetes.lib.umich.edu',
      },
    },
  },

  _images+:: {
    patron_account: {
      web: 'docker.pkg.github.com/mlibrary/patron_account/patron_account:latest',
    },
  },
} +
(import 'ksonnet-util/kausal.libsonnet') +
(import 'patron-account/testing-config.libsonnet') +
(import 'patron-account/patron-account.libsonnet')

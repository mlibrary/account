{
  _config+:: {
    patron_account: {
      web: {
        name: 'web',
        port: 4567,
        host: 'accounts.lib.umich.edu',
      },
    },
  },

  _images+:: {
    patron_account: {
      /* specific commit hash for deploying */
      web: 'docker.pkg.github.com/mlibrary/patron_account/patron_account',
    },
  },
} +
(import 'ksonnet-util/kausal.libsonnet') +
(import 'patron-account/production-config.libsonnet') +
(import 'patron-account/patron-account.libsonnet')

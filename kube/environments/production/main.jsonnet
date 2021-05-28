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
      web: 'mlibrary/patron-account-unstable',
    },
  },
} +
(import 'ksonnet-util/kausal.libsonnet') +
(import 'patron-account/production-config.libsonnet') +
(import 'patron-account/patron-account.libsonnet')

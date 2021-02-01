(import 'patron-account/patron-account.libsonnet') +
{
  _config+:: {
    // patron_account: {
    //   web: {
    //     name: 'web',
    //     port: 4567,
    //     host: 'testing.patron-account.kubernetes.lib.umich.edu',
    //   },
    // },
  },

  _images+:: {
    patron_account: {
      web: 'mlibrary/patron-account-unstable:830ce82176d418fc78ee33047ac74bfc0622b2e6',
    },
  },
}

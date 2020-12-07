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
      web: 'mlibrary/patron-account-unstable',
    },
  },
}

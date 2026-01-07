server "44.204.219.122",
  user: "ubuntu",
  roles: %w{app db web},
  primary: true,
  ssh_options: {
    keys: %w(~/.ssh/id_ed25519),
    forward_agent: false,
    auth_methods: %w(publickey)
  }

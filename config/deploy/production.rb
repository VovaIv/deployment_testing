server "3.235.132.124",
  user: "ubuntu",
  roles: %w{app db web},
  primary: true,
  ssh_options: {
    keys: ["~/Downloads/vovan.pem"],
    forward_agent: true,
    auth_methods: %w(publickey)
  }

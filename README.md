# Cloud Stack Lang

  [![Status](https://img.shields.io/badge/status-active-success.svg)]()
  [![GitHub Issues](https://img.shields.io/github/issues/bubulemaster/cloud_stack_lang.svg)](https://github.com/bubulemaster/cloud_stack_lang/issues)
  [![GitHub Pull Requests](https://img.shields.io/github/issues-pr/bubulemaster/cloud_stack_lang.svg)](https://github.com/bubulemaster/cloud_stack_lang/pulls)
  [![License](https://img.shields.io/badge/license-Apache2-blue.svg)](/LICENSE)

---

## About Cloud Stack Lang
**Cloud Stack Lang** (CSL) is a new way to use native cloud IaaC like CloudFormation for AWS.

Against [Terraform](https://www.terraform.io), CSL want provide an unique syntaxe to use native cloud provide IaaC, like [CloudFormation](https://aws.amazon.com/cloudformation), [Azure Resource Manager](https://docs.microsoft.com/azure/azure-resource-manager/management/overview) or [Google Cloud Deployment Manager](https://cloud.google.com/deployment-manager).

Don't override anything, just simple DSL to generate native cloud file IaaC.


## Compatibility
| Cloud Provider  | Technology                      | Supported   |
|-----------------|---------------------------------|:-----------:|
| Amazon AWS      | CloudFormation                  | in progress |
| Microsoft Azure | Azure Resource Manager          | not yet     |
| Google GCP      | Google Cloud Deployment Manager | not yet     |

### Prerequisites
To use **Cloud Stack Lang** you need install [Erlang/OTP 22](https://www.erlang.org/downloads). Example under Ubuntu 18.04:

```bash
$ sudo apt-get update

# Adding Repository
$ curl https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb --output /tmp/erlang-solutions_2.0_all.deb
$ sudo dpkg -i /tmp/erlang-solutions_2.0_all.deb
$ rm /tmp/erlang-solutions_2.0_all.deb

# Install Erlang
$ sudo apt-get update
$ sudo apt-get install -y esl-erlang
```

### Installing and running
Just get binary from [GitHub release repository](https://github.com/bubulemaster/red-stream-lollipop/releases) and put it in somewhere what you want.

./csl -f example/example01.csl

See [example](./example/) for more options.

---
## Contributing

Contributions, issues and feature requests are welcome!

Feel free to check [issues page](https://github.com/bubulemaster/cloud_stack_lang/issue).

### Prerequisites
To build **Cloud Stack Lang** you need install [Erlang/OTP 22](https://www.erlang.org/downloads) and [Elixir](https://elixir-lang.org) > 1.10. Example under Ubuntu 18.04:

```bash
$ sudo apt-get update

# Adding Repository
$ curl https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb --output /tmp/erlang-solutions_2.0_all.deb
$ sudo dpkg -i /tmp/erlang-solutions_2.0_all.deb
$ rm /tmp/erlang-solutions_2.0_all.deb

# Install Erlang
$ sudo apt-get update
$ sudo apt-get install -y esl-erlang

# Install Elixir
$ sudo apt-get update
$ sudo apt-get install -y elixir
$ mix local.hex --force
```

### Build
Just run:
```
$ mix escript.build
```

### Running the tests
Just run:
```
$ mix test
```

### Coding style
Code style is formatted by `mix format`.

---

## Authors
- [bubulemaster](https://github.com/bubulemaster) - Idea & Initial work

---

## License
Copyright © MARTINEAU Emeric ([bubulemaster](https://github.com/bubulemaster)).

This project is Apache 2 licensed.

# Cloud Stack Lang

  [![Status](https://img.shields.io/badge/status-active-success.svg)]()
  [![GitHub Issues](https://img.shields.io/github/issues/emeric-martineau/cloud_stack_lang.svg)](https://github.com/emeric-martineau/cloud_stack_lang/issues)
  [![GitHub Pull Requests](https://img.shields.io/github/issues-pr/emeric-martineau/cloud_stack_lang.svg)](https://github.com/emeric-martineau/cloud_stack_lang/pulls)
  [![License](https://img.shields.io/badge/license-Apache2-blue.svg)](docs/LICENSE.md)

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

## User documentation

See in `docs` folder or use menu for more informations.

## Installing and running

See [Installation](docs/INSTALL.md) for more informations.

---

## Contributing

See [Contributing](docs/CONTRIBUTING.md) for more informations.

## Generate this documentation

This documentation use [Docpress](https://github.com/docpress/docpress).

```bash
# Under Ubuntu 18.04

$ sudo apt-get update && \
    apt-get install -y \
    nodejs npm git

$ npm install -g docpress

# In root folder of Cloud Stack Lang repository
$ docpress b

```

---

## Authors

- [Emeric MARTINEAU](https://github.com/emeric-martineau) - Idea & Initial work

---

## License

Copyright © MARTINEAU Emeric ([emeric-martineau](https://github.com/emeric-martineau)).

This project is Apache 2 licensed.

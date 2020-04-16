# Installation

## Prerequisites

To use **Cloud Stack Lang** you need install
[Erlang/OTP 22](https://www.erlang.org/downloads). Example for Ubuntu 18.04:

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

## Running

Just get binary from
[GitHub release repository](https://github.com/emeric-martineau/cloud_stack_lang/releases)
and put it in somewhere what you want.

```
./csl doc/examples/example01.csl
```

See [examples](EXAMPLES.md) for more options.

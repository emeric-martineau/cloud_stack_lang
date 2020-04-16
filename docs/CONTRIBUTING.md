# Contributing

Contributions, issues and feature requests are welcome!

Feel free to check [issues page](https://github.com/emeric-martineau/cloud_stack_lang/issue).

## Prerequisites

To build **Cloud Stack Lang** you need install
[Erlang/OTP 22](https://www.erlang.org/downloads) and
[Elixir](https://elixir-lang.org) > 1.10.

Example for Ubuntu 18.04:

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

## Build

Just run:
```
$ mix escript.build
```

## Running the tests
Just run:
```
$ mix test
```

## Coding style

Code style is formatted by `mix format`.
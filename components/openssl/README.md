[![Build Status](https://dev.azure.com/chefcorp-partnerengineering/Chef%20Base%20Plans/_apis/build/status/chef-base-plans.openssl?branchName=master)](https://dev.azure.com/chefcorp-partnerengineering/Chef%20Base%20Plans/_build/latest?definitionId=119&branchName=master)

# openssl

OpenSSL is an open source project that provides a robust, commercial-grade, and full-featured toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols. It is also a general-purpose cryptography library.  See [documentation](https://www.openssl.org)

## Maintainers

* The Core Planners: <chef-core-planners@chef.io>

## Type of Package

Binary package

### Use as Dependency

Binary packages can be set as runtime or build time dependencies. See [Defining your dependencies](https://www.habitat.sh/docs/developing-packages/developing-packages/#sts=Define%20Your%20Dependencies) for more information.

To add core/openssl as a dependency, you can add one of the following to your plan file.

##### Buildtime Dependency

> pkg_build_deps=(core/openssl)

##### Runtime dependency

> pkg_deps=(core/openssl)

### Use as Tool

#### Installation

To install this plan, you should run the following commands to first install, and then link the binaries this plan creates.

``hab pkg install core/openssl --binlink``

will add the following binary to the PATH:

* /bin/openssl

For example:

```bash
$ hab pkg install core/openssl --binlink
» Installing core/openssl
☁ Determining latest version of core/openssl in the 'stable' channel
→ Using core/openssl/1.0.2t/20200306005450
★ Install of core/openssl/1.0.2t/20200306005450 complete with 0 new packages installed.
» Binlinking openssl from core/openssl/1.0.2t/20200306005450 into /bin
★ Binlinked openssl from core/openssl/1.0.2t/20200306005450 to /bin/openssl
```

#### Using an example binary

You can now use the binary as normal.  For example:

``/bin/openssl --help`` or ``openssl --help``

```bash
$ openssl --help
...
...
Standard commands
asn1parse         ca                ciphers           cms
crl               crl2pkcs7         dgst              dh
dhparam           dsa               dsaparam          ec
ecparam           enc               engine            errstr
gendh             gendsa            genpkey           genrsa
...
...
```

[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/haveged.svg)](https://forge.puppetlabs.com/simp/haveged)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/haveged.svg)](https://forge.puppetlabs.com/simp/haveged)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
* [Module Description](#module-description)
* [Setup](#setup)
  * [Setup Requirements](#setup-requirements)
  * [Beginning with haveged](#beginning-with-haveged)
* [Usage](#usage)
  * [Use a higher threshold of available entropy](#use-a-higher-threshold-of-available-entropy)
* [Reference](#reference)
  * [Facts](#facts)
      * [Fact: `haveged_startup_provider`](#fact-haveged_startup_provider)
      * [Fact: `haveged__rhgd_enabled`](#fact-haveged__rhgd_enabled)
* [Development](#development)

<!-- vim-markdown-toc -->

## Overview

Install and manage the HAVEGE daemon, `haveged`.

By default, the module will configure, but not enable `haveged` if `rngd` is
running on the target system. While there is generally no harm in running two
entropy generators, it is not necessary and adds to the overall system load.

If you want to force `haveged` to run, set
`haveged::service::force_if_rngd_running: true` in Hiera.

Only `systemd`-based systems are supported at this time.

## Module Description

The HAVEGE daemon provides a random number generator based on the HAVEGE
(HArdware Volatile Entropy Gathering and Expansion) algorithm. This module
provides a way of installing and setting up the daemon in your environment.

## Setup

### Setup Requirements

The `haveged` package is part of the
[EPEL](https://fedoraproject.org/wiki/EPEL) yum repository, so this repository
must be enabled on Enterprise Linux to be able to install the package.

### Beginning with haveged

Declare the haveged class to run the haveged daemon with the default
parameters.

```puppet
include 'haveged'
```

This installs the haveged package and starts the service using default
parameters.

See the following sections for a detailed description of the available
configuration options.

## Usage

### Use a higher threshold of available entropy

```yaml
---
haveged::write_wakeup_threshold: 2048
```

## Reference

See [REFERENCE.md](./REFERENCE.md) for additional API documentation.

### Facts

This module provides the following facts.

##### Fact: `haveged_startup_provider`

The startup system used on the node. The implementation uses the process name
of PID 1 to resolve the fact. The value is either `systemd` or `init`.

##### Fact: `haveged__rhgd_enabled`

Returns `true` or `false` depending on whether or not `rngd` is enabled on the
target system.

## Development

Feel free to send pull requests for new features and other operating systems.

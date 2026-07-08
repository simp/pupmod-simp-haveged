# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-haveged` is a small SIMP Puppet module that installs, configures, and
manages the **HAVEGE daemon** (`haveged`) — a userspace entropy source that
feeds the kernel random pool. It installs the `haveged` package, drops a
`systemd` unit override that rewrites the daemon's `ExecStart` with tunable
collection-buffer / cache / wakeup-threshold flags, and runs and enables the
`haveged` service.

The module is entropy-aware about `rngd`: if the `rngd` daemon is already
running (detected by a custom fact), `haveged` is deliberately **stopped and
masked** rather than started, to avoid running two competing entropy daemons
(`manifests/service.pp:23-28`). It can also be fully removed (package purged,
service stopped/disabled) by setting `haveged::package_ensure` to `absent`
(`manifests/init.pp:55-92`), and the whole module can be switched off globally
via the `simp_options::haveged` toggle (`manifests/init.pp:51`).

### Business logic

The module is four public classes and no defines. The entry class fans out to
`package`, `service`, and (unless removing) `config` via `contain`. None of the
classes are `assert_private()`'d, but the three sub-classes are only meant to be
driven through `haveged` — they read their defaults back from the `haveged::*`
namespace with `defined()`/`getvar()`.

- **`haveged` (`manifests/init.pp:37-94`)** — Public entry class; consumers
  `include 'haveged'`. Key parameters (`init.pp:38-46`):
  - `$buffer_size`, `$data_cache_size`, `$instruction_cache_size`
    (`Optional[Variant[String,Integer]]`, default `undef`) — HAVEGE tuning
    knobs in KB; only emitted into the unit override when set.
  - `$write_wakeup_threshold` (`Variant[String,Integer]`, default `1024`) — the
    entropy-bit low-water mark that makes the daemon generate more data.
  - `$service_name` (`String[1]`, default `'haveged'`),
    `$service_enable` (`Boolean`, default `true`),
    `$service_ensure` (`Variant[Boolean,String[1]]`, default `'running'`).
  - `$package_name` (`String[1]`, default `'haveged'`).
  - `$package_ensure` (`Variant[Boolean,Simplib::PackageEnsure]`) — defaults to
    `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`
    (`init.pp:46`).

  Control flow (`init.pp:49-93`):
  - `simplib::assert_metadata($module_name)` first (`init.pp:49`).
  - The **entire body is gated** on
    `simplib::lookup('simp_options::haveged', { 'default_value' => true })`
    (`init.pp:51`) — when that global toggle is `false`, the module manages
    nothing.
  - **Package-ensure canonicalization** (`init.pp:55-60`): `true`→`'present'`,
    `false`/`'absent'`→`'purged'`, otherwise passthrough, into `$_package_ensure`.
  - **Service-ensure canonicalization** (`init.pp:65-77`): if
    `$_package_ensure == 'purged'`, force `$_service_ensure = 'stopped'` and
    `$_service_enable = false`; otherwise `true`→`'running'`, `false`→`'stopped'`,
    else passthrough, and keep `$service_enable`.
  - **Containment + ordering** (`init.pp:79-92`): always
    `contain 'haveged::package'` and `contain 'haveged::service'`. On **purge**,
    order `service -> package` (stop before removal) and **do not** contain
    `config`. Otherwise contain `config` and wire
    `package ~> service`, `package -> config`, `config ~> service`.

- **`haveged::package` (`manifests/package.pp:9-23`)** — Manages the package.
  Params default back from `haveged::*` via `defined()`/`getvar()`
  (`package.pp:10-11`): `$package_name` (else `'haveged'`) and `$package_ensure`
  (from `haveged::_package_ensure`, else `'present'`). Works around
  puppetlabs PUP-1295 (`package.pp:13-14`): on `RedHat` family a requested
  `'purged'` is downgraded to `'absent'` (`package.pp:15-20`), then
  `package { $package_name: ensure => $_package_ensure }` (`package.pp:22`).

- **`haveged::service` (`manifests/service.pp:17-35`)** — Manages the service.
  Params default back from `haveged::*` (`service.pp:18-20`): `$service_name`,
  `$service_ensure` (from `haveged::_service_ensure`), `$service_enable` (from
  `haveged::_service_enable`), plus `$force_if_rngd_running` (`Boolean`, default
  `false`). **rngd guard** (`service.pp:23-28`): if the `haveged__rngd_enabled`
  fact is true and `$force_if_rngd_running` is false, the service is set
  `ensure => 'stopped', enable => 'mask'`. Otherwise it honors
  `$service_ensure`/`$service_enable` (`service.pp:30-33`).

- **`haveged::config` (`manifests/config.pp:16-54`)** — Writes the systemd
  drop-in. Params default back from `haveged::*` (`config.pp:17-20`). Builds an
  options hash `{ '-b' => buffer, '-d' => data_cache, '-i' => instr_cache,
  '-w' => wakeup }` (`config.pp:22-27`), strips `undef` values
  (`delete_undef_values`, `config.pp:30`), joins into a flag string
  (`join_keys_to_values` + `join`, `config.pp:33-36`), and renders a heredoc
  systemd `[Service]` override that clears the stock `ExecStart` and sets
  `ExecStart=/usr/sbin/haveged --Foreground --verbose=1 ${_opts}`
  (`config.pp:38-48`). It is applied via
  `systemd::dropin_file { 'haveged_settings.conf': unit => 'haveged.service' }`
  (`config.pp:50-53`).

### Gotchas / non-obvious details

- **The whole module is gated on `simp_options::haveged`** (default `true`,
  `init.pp:51`). Set `simp_options::haveged: false` in Hiera and `include
  'haveged'` becomes a no-op — nothing is managed.
- **rngd wins over haveged by default.** When `rngd` is running, haveged is
  stopped and its unit is **masked** (`service.pp:23-28`); set
  `haveged::service::force_if_rngd_running: true` to run both. The
  `haveged__rngd_enabled` fact drives this (`lib/facter/haveged__rngd_enabled.rb`).
- **`absent` means purge.** `haveged::package_ensure` values `false` or
  `'absent'` canonicalize to `'purged'` (`init.pp:55-60`), which also forces the
  service stopped/disabled and skips `config` (`init.pp:65-92`). On RedHat-family
  the package resource then downgrades `'purged'`→`'absent'` to dodge PUP-1295
  (`package.pp:15-20`).
- **Sub-class parameter defaults are read from the parent** via
  `defined('$haveged::...') ? { true => getvar(...), default => ... }`
  (`package.pp:10-11`, `service.pp:18-20`, `config.pp:17-20`). The `service`
  and `package` sub-classes read the **canonicalized** `haveged::_service_ensure`
  / `haveged::_service_enable` / `haveged::_package_ensure`, so applying them
  standalone (outside `include 'haveged'`) falls back to hard-coded defaults.
- **`haveged_startup_provider` fact is defined but unused in the manifests.**
  `lib/facter/haveged_startup_provider.rb` reads PID 1's command from
  `/proc/1/comm`; no manifest references it (only its unit spec does). Leave it
  unless you are intentionally removing dead code.
- **`config` uses stdlib 3.x-style function names** (`delete_undef_values`,
  `join_keys_to_values`, `join`, `config.pp:30-36`) rather than the namespaced
  `stdlib::` equivalents. This is legacy style; matches the rest of the module.
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  the manifest consumes the `simp_options::*` seam via `simplib::lookup`
  (provided by `simp/simplib`). There are no fixture entries for it either; the
  `simp_options::*` lookups simply fall through to their `default_value`.

## The `simp_options` / `simplib::lookup` seam

This is the module's SIMP configuration seam. Both calls are in
`manifests/init.pp`:

| Line | Key | `default_value` |
|------|-----|-----------------|
| `init.pp:46` | `simp_options::package_ensure` | `'installed'` |
| `init.pp:51` | `simp_options::haveged` | `true` |

`simp_options::haveged` is a module-wide on/off switch; `simp_options::package_ensure`
sets the default package state. Keep routing SIMP feature toggles through
`simplib::lookup('simp_options::*', { 'default_value' => ... })` with an
explicit default rather than assuming `simp_options` is included.

## Dependencies

Module dependencies (from `metadata.json`):

- `puppet/systemd` `>= 4.0.2 < 8.0.0` — provides
  `systemd::dropin_file` (used in `config.pp`).
- `simp/simplib` `>= 4.9.0 < 5.0.0` — provides `simplib::lookup`,
  `simplib::assert_metadata`, and the `Simplib::PackageEnsure` data type.
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` — provides `delete_undef_values`,
  `join_keys_to_values`, `join`.

Optional dependencies: **none** (`metadata.json` has no
`simp.optional_dependencies` key).

Fixture-only dependencies (from `.fixtures.yml`, checked out for test
compilation): `stdlib`, `simplib`, `systemd` (the latter pinned to the SIMP
fork's `simp-master` branch). These mirror the three runtime deps above; there
is no `simp_options` fixture.

Runtime requirement (from `metadata.json` `requirements`): `puppet
>= 7.0.0 < 9.0.0`. (SIMP is migrating Puppet → OpenVox; when
`metadata.json` switches this to `openvox`, update this line to match.)

Supported OS matrix (from `metadata.json`): Amazon 2; RedHat 7/8/9; CentOS
7/8/9; OracleLinux 7/8/9; AlmaLinux 8/9; Rocky 8/9.

## Repository layout

- `manifests/init.pp` — `haveged` entry class: `simp_options` gating,
  ensure canonicalization, containment/ordering.
- `manifests/package.pp` — `haveged::package` class (package resource,
  PUP-1295 workaround).
- `manifests/service.pp` — `haveged::service` class (rngd guard, service
  resource).
- `manifests/config.pp` — `haveged::config` class (systemd drop-in with the
  HAVEGE flag string).
- `lib/facter/haveged__rngd_enabled.rb` — custom fact: is `rngd` running
  (via `pgrep`)? Drives the rngd guard in `service.pp`.
- `lib/facter/haveged_startup_provider.rb` — custom fact: PID 1's command from
  `/proc/1/comm` (currently unused by the manifests).
- `hiera.yaml` — module data hierarchy (v5): OSFamily+release → OS family →
  OS → virtual → common. **Note: there is no `data/` directory** — the module
  ships no bundled Hiera data, only the hierarchy definition.
- `metadata.json` — deps, OS matrix, Puppet requirement.
- `spec/classes/{init,package,service,config}_spec.rb` — rspec-puppet unit
  tests.
- `spec/unit/facter/*_spec.rb` — unit tests for the two custom facts.
- `spec/fixtures/hieradata/disabled.yaml` — hieradata used by the disabled-state
  specs.
- `spec/acceptance/suites/default/00_default_spec.rb` — beaker acceptance suite
  (installs, checks the rngd/mask behavior across a reboot, then purges and
  re-checks); nodesets under `spec/acceptance/nodesets/`
  (`almalinux`, `amzn2`, `default`, `oel`, `rocky`).
- `REFERENCE.md` — generated Puppet Strings reference.
- No `types/` or `templates/` — the module defines no custom Puppet data types
  (it uses `Simplib::PackageEnsure` from `simp/simplib`) and no ERB/EPP
  templates (the systemd override is an inline heredoc in `config.pp`).
- **Acceptance does NOT run in GitHub Actions CI.** `.github/workflows/pr_tests.yml`
  has only syntax/style/file/releng/spec jobs — there is **no** `acceptance`
  job. Beaker acceptance is driven from **GitLab CI** (`.gitlab-ci.yml`, `stage:
  acceptance`), which runs `bundle exec rake beaker:suites[default,<nodeset>]`
  (nodesets `default`, `oel`, `amzn2`; several jobs also with `BEAKER_fips=yes`).

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run a single class spec
bundle exec rspec spec/classes/init_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite
bundle exec rake beaker:suites[default]
```

The `Gemfile` is puppetsync-managed and pins gems via env-var fallbacks rather
than fixed versions: `simp-rake-helpers` `>= 5.21.0 < 6`,
`simp-rspec-puppet-facts` `~> 3.7`, `simp-beaker-helpers` `>= 1.32.1 < 2`, with
`puppet` `>= 7 < 9`. Note the `Gemfile` does **not** list `rubocop`, and the
`ruby-style` job in `pr_tests.yml` is disabled (`if: false`), so
`rake rubocop` is not exercised in GitHub CI.

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on each class —
  they drive `REFERENCE.md`. Regenerate `REFERENCE.md` after changing docs or
  parameters.
- Keep the sub-classes (`package`, `service`, `config`) driven through the
  `haveged` entry class; their defaults intentionally read back from the
  `haveged::*` namespace via `defined()`/`getvar()`.
- Route SIMP feature toggles through
  `simplib::lookup('simp_options::*', { 'default_value' => ... })` rather than
  assuming `simp_options` is included.
- `Gemfile`, `.github/workflows/pr_tests.yml`, and the other baseline files
  carry a **puppetsync** notice — they are baseline-managed and the next sync
  overwrites local edits. Push changes to those files upstream to the baseline,
  not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in the manifests.

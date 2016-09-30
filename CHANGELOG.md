## 2016-09-29 - Release 0.3.2
### Summary
Fixed malformed `pe` dependency in `metadata.json`

#### Authors
- Chris Tessmer <chris.tessmer@onyxpoint.com>

#### Features
- Fixed syntax to enable publishing to the Forge

## 2016-07-07 - Release 0.3.1
### Summary
Updated module for auto lua spec generation

#### Authors
- Nick Markowski <nmarkowski@keywcorp.com>

#### Features
- Added missing requires file and added dependency on simplib
- Modified module to auto-generate lua spec

## 2016-06-01 - Release 0.3.0
### Summary
Massive Refactor

#### Authors
- Trevor Vaughan <tvaughan@onyxpoint.com>

#### Features
- Refactored the module to use the latest best practices and eliminate issues
  with doing an 'include' of the individual sub-classes.
- Worked around a bug with the yum provider and the 'purged' parameter
- Fixed some class ordering
- Added acceptance tests for EL6 and EL7
- Updated the rspec tests to properly work around OEL issues with facts

## 2015-10-11 - Release 0.2.0
### Summary
This release adds support for RedHat based systems.

#### Authors
- Stefan Möding

#### Features
- Add `haveged_startup_provider` fact to check whether the node uses `init` or `systemd`.

## 2015-06-09 - Release 0.1.0
### Summary
Initial release.

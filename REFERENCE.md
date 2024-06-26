# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`haveged`](#haveged): Manage HAVEGEd  == Sample Usage:    class { 'haveged':     write_wakeup_threshold => 1024,   }
* [`haveged::config`](#haveged--config): Manage the HAVEGEd configuration file
* [`haveged::package`](#haveged--package): Manage the haveged package
* [`haveged::service`](#haveged--service): Manage the HAVEGEd service

## Classes

### <a name="haveged"></a>`haveged`

Manage HAVEGEd

== Sample Usage:

  class { 'haveged':
    write_wakeup_threshold => 1024,
  }

#### Parameters

The following parameters are available in the `haveged` class:

* [`buffer_size`](#-haveged--buffer_size)
* [`data_cache_size`](#-haveged--data_cache_size)
* [`instruction_cache_size`](#-haveged--instruction_cache_size)
* [`write_wakeup_threshold`](#-haveged--write_wakeup_threshold)
* [`service_name`](#-haveged--service_name)
* [`service_ensure`](#-haveged--service_ensure)
* [`service_enable`](#-haveged--service_enable)
* [`package_name`](#-haveged--package_name)
* [`package_ensure`](#-haveged--package_ensure)

##### <a name="-haveged--buffer_size"></a>`buffer_size`

Data type: `Optional[Variant[String,Integer]]`

The size of the collection buffer in KB

Default value: `undef`

##### <a name="-haveged--data_cache_size"></a>`data_cache_size`

Data type: `Optional[Variant[String,Integer]]`

The data cache size in KB

Default value: `undef`

##### <a name="-haveged--instruction_cache_size"></a>`instruction_cache_size`

Data type: `Optional[Variant[String,Integer]]`

The instruction cache size in KB. Default is 16 or as determined by cpuid

Default value: `undef`

##### <a name="-haveged--write_wakeup_threshold"></a>`write_wakeup_threshold`

Data type: `Variant[String,Integer]`

The haveged daemon generates more data if the number of entropy bits
falls below this value

Default value: `1024`

##### <a name="-haveged--service_name"></a>`service_name`

Data type: `String[1]`

The name of the service to manage

Default value: `'haveged'`

##### <a name="-haveged--service_ensure"></a>`service_ensure`

Data type: `Variant[Boolean,String[1]]`

Whether the service should be running

Default value: `'running'`

##### <a name="-haveged--service_enable"></a>`service_enable`

Data type: `Boolean`

Whether the service should be enabled to start at boot time

Default value: `true`

##### <a name="-haveged--package_name"></a>`package_name`

Data type: `String[1]`

The name of the package to manage

Default value: `'haveged'`

##### <a name="-haveged--package_ensure"></a>`package_ensure`

Data type: `Variant[Boolean,Simplib::PackageEnsure]`

Ensure parameter passed onto Package resources. Default: 'present'

Default value: `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`

### <a name="haveged--config"></a>`haveged::config`

Manage the HAVEGEd configuration file

#### Parameters

The following parameters are available in the `haveged::config` class:

* [`buffer_size`](#-haveged--config--buffer_size)
* [`data_cache_size`](#-haveged--config--data_cache_size)
* [`instruction_cache_size`](#-haveged--config--instruction_cache_size)
* [`write_wakeup_threshold`](#-haveged--config--write_wakeup_threshold)

##### <a name="-haveged--config--buffer_size"></a>`buffer_size`

Data type: `Optional[Variant[Pattern['^[0-9]+$'],Integer]]`

The size of the collection buffer in KB

Default value: `defined('$haveged::buffer_size') ? { true => getvar('haveged::buffer_size'), default => undef`

##### <a name="-haveged--config--data_cache_size"></a>`data_cache_size`

Data type: `Optional[Variant[Pattern['^[0-9]+$'],Integer]]`

The data cache size in KB

Default value: `defined('$haveged::data_cache_size') ? { true => getvar('haveged::data_cache_size'), default => undef`

##### <a name="-haveged--config--instruction_cache_size"></a>`instruction_cache_size`

Data type: `Optional[Variant[Pattern['^[0-9]+$'],Integer]]`

The instruction cache size in KB

Default value: `defined('$haveged::instruction_cache_size') ? { true => getvar('haveged::instruction_cache_size'), default => undef`

##### <a name="-haveged--config--write_wakeup_threshold"></a>`write_wakeup_threshold`

Data type: `Optional[Variant[Pattern['^[0-9]+$'],Integer]]`

The haveged daemon generates more data if the number of entropy bits
falls below this value

Default value: `defined('$haveged::write_wakeup_threshold') ? { true => getvar('haveged::write_wakeup_threshold'), default => undef`

### <a name="haveged--package"></a>`haveged::package`

Manage the haveged package

#### Parameters

The following parameters are available in the `haveged::package` class:

* [`package_name`](#-haveged--package--package_name)
* [`package_ensure`](#-haveged--package--package_ensure)

##### <a name="-haveged--package--package_name"></a>`package_name`

Data type: `String[1]`

The name of the package to manage

Default value: `defined('$haveged::package_name') ? { true => getvar('haveged::package_name'), default => 'haveged'`

##### <a name="-haveged--package--package_ensure"></a>`package_ensure`

Data type: `Simplib::PackageEnsure`

Ensure parameter passed onto Package resources

Default value: `defined('$haveged::_package_ensure') ? { true => getvar('haveged::_package_ensure'), default => 'present'`

### <a name="haveged--service"></a>`haveged::service`

Manage the HAVEGEd service

#### Parameters

The following parameters are available in the `haveged::service` class:

* [`service_name`](#-haveged--service--service_name)
* [`service_ensure`](#-haveged--service--service_ensure)
* [`service_enable`](#-haveged--service--service_enable)
* [`force_if_rngd_running`](#-haveged--service--force_if_rngd_running)

##### <a name="-haveged--service--service_name"></a>`service_name`

Data type: `String[1]`

The name of the service to manage

Default value: `defined('$haveged::service_name') ? { true => getvar('haveged::service_name'), default => 'haveged'`

##### <a name="-haveged--service--service_ensure"></a>`service_ensure`

Data type: `String[1]`

Whether the service should be running

Default value: `defined('$haveged::_service_ensure') ? { true => getvar('haveged::_service_ensure'), default => 'running'`

##### <a name="-haveged--service--service_enable"></a>`service_enable`

Data type: `Boolean`

Whether the service should be enabled to start at boot time

Default value: `defined('$haveged::_service_enable') ? { true => getvar('haveged::_service_enable'), default => true`

##### <a name="-haveged--service--force_if_rngd_running"></a>`force_if_rngd_running`

Data type: `Boolean`

Will force haveged to start even though RNGD is already running

* While this should not harm your system in most cases, it is also adding
  an unnecessary process running on the system

Default value: `false`


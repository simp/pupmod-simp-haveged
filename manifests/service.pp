# Manage the HAVEGEd service
#
# @param service_name
#   The name of the service to manage
#
# @param service_ensure
#   Whether the service should be running
#
# @param service_enable
#   Whether the service should be enabled to start at boot time
#
# @param force_if_rngd_running
#   Will force haveged to start even though RNGD is already running
#
#   * While this should not harm your system in most cases, it is also adding
#     an unnecessary process running on the system
class haveged::service (
  String[1] $service_name   = defined('$haveged::service_name') ? { true => getvar('haveged::service_name'), default => 'haveged' },
  String[1] $service_ensure = defined('$haveged::_service_ensure') ? { true => getvar('haveged::_service_ensure'), default => 'running' },
  Boolean $service_enable = defined('$haveged::_service_enable') ? { true => getvar('haveged::_service_enable'), default => true },
  Boolean $force_if_rngd_running = false
) {

  if $facts['haveged__rngd_enabled'] and !$force_if_rngd_running {
    service {$service_name:
      ensure => 'stopped',
      enable => false
    }
  }
  else {
    service { $service_name:
      ensure => $service_ensure,
      enable => $service_enable
    }
  }
}

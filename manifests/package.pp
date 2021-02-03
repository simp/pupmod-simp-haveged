# Manage the haveged package
#
# @param package_name
#   The name of the package to manage
#
# @param package_ensure
#   Ensure parameter passed onto Package resources
#
class haveged::package (
  String[1]              $package_name   = defined('$haveged::package_name') ? { true => getvar('haveged::package_name'), default => 'haveged' },
  Simplib::PackageEnsure $package_ensure = defined('$haveged::_package_ensure') ? { true => getvar('haveged::_package_ensure'), default => 'present' }
) {
  # Working around a bug in the package type
  # https://tickets.puppetlabs.com/browse/PUP-1295
  if ($facts['osfamily'] == 'RedHat') and ($package_ensure == 'purged') {
    $_package_ensure = 'absent'
  }
  else {
    $_package_ensure = $package_ensure
  }

  package { $package_name: ensure => $_package_ensure }
}

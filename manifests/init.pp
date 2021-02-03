# Manage HAVEGEd
#
# @param buffer_size
#   The size of the collection buffer in KB
#
# @param data_cache_size
#   The data cache size in KB
#
# @param instruction_cache_size
#   The instruction cache size in KB. Default is 16 or as determined by cpuid
#
# @param write_wakeup_threshold
#   The haveged daemon generates more data if the number of entropy bits
#   falls below this value
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
# @param package_name
#   The name of the package to manage
#
# @param package_ensure
#   Ensure parameter passed onto Package resources. Default: 'present'
#
# == Sample Usage:
#
#   class { 'haveged':
#     write_wakeup_threshold => 1024,
#   }
#
class haveged (
  Optional[Variant[String,Integer]]       $buffer_size            = undef,
  Optional[Variant[String,Integer]]       $data_cache_size        = undef,
  Optional[Variant[String,Integer]]       $instruction_cache_size = undef,
  Optional[Variant[String,Integer]]       $write_wakeup_threshold = 1024,
  String[1]                               $service_name           = 'haveged',
  Boolean                                 $service_enable         = true,
  Variant[Boolean,String[1]]              $service_ensure         = 'running',
  String[1]                               $package_name           = 'haveged',
  Variant[Boolean,Simplib::PackageEnsure] $package_ensure         = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  simplib::assert_metadata($module_name)

  if simplib::lookup('simp_options::haveged', { 'default_value' => true }) {
    #
    # Canonicalize parameter package_ensure
    #
    $_package_ensure = $package_ensure ? {
      true     => 'present',
      false    => 'purged',
      'absent' => 'purged',
      default  => $package_ensure,
    }

    #
    # Canonicalize parameter service_ensure
    #
    if ($_package_ensure == 'purged') {
      $_service_ensure = 'stopped'
      $_service_enable = false
    }
    else {
      $_service_ensure = $service_ensure ? {
        true    => 'running',
        false   => 'stopped',
        default => $service_ensure,
      }

      $_service_enable = $service_enable
    }

    contain 'haveged::package'
    contain 'haveged::service'

    if ($_package_ensure == 'purged') {
      # Allow stopping before removal
      Class['haveged::service'] -> Class['haveged::package']
    }
    else {
      contain 'haveged::config'

      Class['haveged::package'] ~> Class['haveged::service']
      Class['haveged::package'] -> Class['haveged::config']
      Class['haveged::config'] ~> Class['haveged::service']
    }
  }
}

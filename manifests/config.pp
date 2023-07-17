# Manage the HAVEGEd configuration file
#
# @param buffer_size
#   The size of the collection buffer in KB
#
# @param data_cache_size
#   The data cache size in KB
#
# @param instruction_cache_size
#   The instruction cache size in KB
#
# @param write_wakeup_threshold
#   The haveged daemon generates more data if the number of entropy bits
#   falls below this value
#
class haveged::config (
  Optional[Variant[Pattern['^[0-9]+$'],Integer]] $buffer_size            =  defined('$haveged::buffer_size') ? { true => getvar('haveged::buffer_size'), default => undef },
  Optional[Variant[Pattern['^[0-9]+$'],Integer]] $data_cache_size        =  defined('$haveged::data_cache_size') ? { true => getvar('haveged::data_cache_size'), default => undef },
  Optional[Variant[Pattern['^[0-9]+$'],Integer]] $instruction_cache_size =  defined('$haveged::instruction_cache_size') ? { true => getvar('haveged::instruction_cache_size'), default => undef },
  Optional[Variant[Pattern['^[0-9]+$'],Integer]] $write_wakeup_threshold =  defined('$haveged::write_wakeup_threshold') ? { true => getvar('haveged::write_wakeup_threshold'), default => undef }
) {
  $_opts_hash = {
    '-b' => $buffer_size,
    '-d' => $data_cache_size,
    '-i' => $instruction_cache_size,
    '-w' => $write_wakeup_threshold,
  }

  # Remove all entries where the value is 'undef'
  $_opts_ok = delete_undef_values($_opts_hash)

  # Concat key and value into array elements
  $_opts_strings = join_keys_to_values($_opts_ok, ' ')

  # Join array elements into one string
  $_opts = join($_opts_strings, ' ')

  $_systemd_conf = @("END")
    # This file managed by Puppet.

    [Service]

    # Clear startup command provided by system config
    ExecStart=

    # Define the new startup command
    ExecStart=/usr/sbin/haveged --Foreground --verbose=1 ${_opts}
    | END

  systemd::dropin_file { 'haveged_settings.conf':
    unit    => 'haveged.service',
    content => $_systemd_conf,
  }
}

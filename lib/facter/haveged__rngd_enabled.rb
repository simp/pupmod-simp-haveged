# frozen_string_literal: true

# Return the provider of the init system by looking at PID 1
Facter.add(:haveged__rngd_enabled) do
  pgrep_cmd = Facter::Util::Resolution.which('pgrep')
  confine { pgrep_cmd }

  setcode do
    Facter::Core::Execution.execute("#{pgrep_cmd} rngd", on_fail: false).strip.empty? ? false : true
  end
end

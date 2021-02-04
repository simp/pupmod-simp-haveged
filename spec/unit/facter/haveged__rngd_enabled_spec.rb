require "spec_helper"

describe 'Facter::Util::Fact' do
  pgrep_path = '/usr/bin/pgrep'

  before do
    Facter.clear
    Facter::Util::Resolution.stubs(:which).with('pgrep').returns(pgrep_path)
  end
  after do
    Facter.clear
  end

  context 'with rngd running' do
    it do
      Facter::Core::Execution.stubs(:execute).with("#{pgrep_path} rngd", on_fail: false).returns("1234\n")
      expect(Facter.fact(:haveged__rngd_enabled).value).to eq(true)
    end
  end

  context 'with rngd stopped' do
    it do
      Facter::Core::Execution.stubs(:execute).with("#{pgrep_path} rngd", on_fail: false).returns("\n")
      expect(Facter.fact(:haveged__rngd_enabled).value).to eq(false)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'Facter::Util::Fact' do
  pgrep_path = '/usr/bin/pgrep'

  before(:each) do
    Facter.clear
    allow(Facter::Util::Resolution).to receive(:which).with('pgrep').and_return(pgrep_path)
  end

  after(:each) do
    Facter.clear
  end

  context 'with rngd running' do
    it do
      allow(Facter::Core::Execution).to receive(:execute).with("#{pgrep_path} rngd", on_fail: false).and_return("1234\n")
      expect(Facter.fact(:haveged__rngd_enabled).value).to eq(true)
    end
  end

  context 'with rngd stopped' do
    it do
      allow(Facter::Core::Execution).to receive(:execute).with("#{pgrep_path} rngd", on_fail: false).and_return("\n")
      expect(Facter.fact(:haveged__rngd_enabled).value).to eq(false)
    end
  end
end

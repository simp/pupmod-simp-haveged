# frozen_string_literal: true

require 'spec_helper'

describe 'Facter::Util::Fact' do
  before(:each) do
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
  end

  after(:each) do
    Facter.clear
  end

  context 'when haveged_startup_provider is /proc/1/comm' do
    it {
      allow(File).to receive(:open).and_return("foo\n")
      expect(Facter.fact(:haveged_startup_provider).value).to eq('foo')
    }
  end

  context 'when haveged_startup_provider raises and exception' do
    it {
      allow(File).to receive(:open) { raise(StandardException) }
      expect(Facter.fact(:haveged_startup_provider).value).to eq('init')
    }
  end
end

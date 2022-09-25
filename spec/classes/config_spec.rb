# frozen_string_literal: true

require 'spec_helper'

describe 'haveged::config' do
  on_supported_os.each do |os, os_facts|
    let :facts do
      os_facts
    end

    context "on #{os} with default parameters" do
      it do
        expect(subject).to contain_systemd__dropin_file('haveged_settings.conf')
          .with_unit('haveged.service')
          .with_content(%r{^ExecStart=.+/haveged --Foreground --verbose=1 $}m)
      end
    end

    context 'when setting data_cache_size' do
      let :params do
        { :data_cache_size => 1103 }
      end

      it do
        expect(subject).to contain_systemd__dropin_file('haveged_settings.conf')
          .with_unit('haveged.service')
          .with_content(%r{^ExecStart=.+/haveged --Foreground --verbose=1 -d 1103$}m)
      end
    end

    context 'when setting all parameters' do
      let :params do
        {
          :buffer_size => 1234,
          :data_cache_size => 1235,
          :instruction_cache_size => 1236,
          :write_wakeup_threshold => 1237
        }
      end

      it do
        expect(subject).to contain_systemd__dropin_file('haveged_settings.conf')
          .with_unit('haveged.service')
          .with_content(%r{^ExecStart=.+/haveged --Foreground --verbose=1 -b 1234 -d 1235 -i 1236 -w 1237$}m)
      end
    end
  end
end

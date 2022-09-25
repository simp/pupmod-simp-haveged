# frozen_string_literal: true

require 'spec_helper'

describe 'haveged' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os} with default parameters" do
      it {
        expect(subject).to contain_class('haveged')

        expect(subject).to contain_class('haveged::package')

        expect(subject).to contain_class('haveged::config') \
          .with_write_wakeup_threshold('1024') \
          .that_requires('Class[haveged::package]') \
          .that_notifies('Class[haveged::service]')

        expect(subject).to contain_class('haveged::service')
      }
    end

    context 'with simp_options::haveged = false' do
      let(:hieradata) { 'disabled' }

      it { is_expected.not_to contain_class('haveged::package') }
      it { is_expected.not_to contain_class('haveged::service') }
      it { is_expected.not_to contain_class('haveged::config') }
    end

    context "on #{os} with service_ensure => stopped" do
      let :params do
        { :service_ensure => 'stopped' }
      end

      it {
        expect(subject).to contain_class('haveged')

        expect(subject).to contain_class('haveged::package')
      }
    end

    context "on #{os} with package parameters defined" do
      let :params do
        {
          :package_name => 'foobar',
          :package_ensure => 'latest'
        }
      end

      it {
        expect(subject).to contain_class('haveged::package') \
          .with_package_name('foobar') \
          .with_package_ensure('latest')
      }
    end

    context "on #{os} with service parameters defined" do
      let :params do
        {
          :service_name => 'foobar',
          :service_enable => true,
          :service_ensure => 'bar'
        }
      end

      it {
        expect(subject).to contain_class('haveged::service') \
          .with_service_name('foobar') \
          .with_service_enable(true) \
          .with_service_ensure('bar')
      }
    end

    context "on #{os} with config parameters defined" do
      let :params do
        {
          :buffer_size => '2',
          :data_cache_size => '3',
          :instruction_cache_size => '5',
          :write_wakeup_threshold => '7'

        }
      end

      it {
        expect(subject).to contain_class('haveged::config') \
          .with_buffer_size('2') \
          .with_data_cache_size('3') \
          .with_instruction_cache_size('5') \
          .with_write_wakeup_threshold('7')
      }
    end

    context "on #{os} with package_ensure => present" do
      let :params do
        {
          :package_ensure => 'present'
        }
      end

      it {
        expect(subject).to contain_class('haveged::package') \
          .with_package_ensure('present')

        expect(subject).to contain_class('haveged::config') \
          .that_requires('Class[haveged::package]') \
          .that_notifies('Class[haveged::service]')

        expect(subject).to contain_class('haveged::config')

        expect(subject).to contain_class('haveged::service') \
          .with_service_ensure('running')
      }
    end

    context "on #{os} with package_ensure => absent" do
      let :params do
        {
          :package_ensure => 'absent'
        }
      end

      it {
        expect(subject).to contain_class('haveged::package') \
          .with_package_ensure('purged')

        expect(subject).to contain_class('haveged::service') \
          .with_service_ensure('stopped') \
          .that_comes_before('Class[haveged::package]')
      }
    end

    context "on #{os} with package_ensure => purged" do
      let :params do
        {
          :package_ensure => 'purged'
        }
      end

      it {
        expect(subject).to contain_class('haveged::package') \
          .with_package_ensure('purged')

        expect(subject).to contain_class('haveged::service') \
          .with_service_ensure('stopped') \
          .that_comes_before('Class[haveged::package]')
      }
    end
  end
end

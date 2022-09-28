# frozen_string_literal: true

require 'spec_helper'

describe 'haveged::package' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default parameters' do
        it {
          expect(subject).to contain_package('haveged')
            .with_ensure('present')
            .with_name('haveged')
        }
      end

      context 'with defined parameters' do
        let :params do
          { :package_name => 'foobar', :package_ensure => 'present' }
        end

        it do
          expect(subject).to contain_package(params[:package_name]).with_ensure(params[:package_ensure])
        end
      end
    end
  end
end

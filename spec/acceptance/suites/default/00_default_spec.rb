# frozen_string_literal: true

require 'spec_helper_acceptance'

test_name 'haveged'

describe 'haveged' do
  let(:manifest) do
    <<-MANIFEST
      include 'haveged'
    MANIFEST
  end

  hosts.each do |host|
    context "on #{host}" do
      # Using puppet_apply as a helper
      it 'works with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'is installed' do
        on(host, 'puppet resource package haveged') do
          expect(stdout).not_to match(%r{ensure\s*=> 'absent'})
        end
      end

      it 'is stopped if rngd is running and remain stopped after reboot' do
        unless on(host, 'pgrep rngd 2>/dev/null', :accept_all_exit_codes => true).stdout.strip.empty?
          on(host, 'puppet resource service haveged') do
            expect(stdout).to match(%r{ensure\s*=> 'stopped'})
            expect(stdout).to match(%r{enable\s*=> 'false'})
          end

          host.reboot

          on(host, 'puppet resource service haveged') do
            expect(stdout).to match(%r{ensure\s*=> 'stopped'})
            expect(stdout).to match(%r{enable\s*=> 'false'})
          end

          on(host, 'pkill rngd')
          apply_manifest_on(host, manifest, :catch_failures => true)
        end
      end

      it 'is running' do
        on(host, 'puppet resource service haveged') do
          expect(stdout).to match(%r{ensure\s*=> 'running'})
          expect(stdout).to match(%r{enable\s*=> 'true'})
        end
      end

      # rubocop:disable Rspec/RepeatedExample
      it 'is idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end
      # rubocop:enable Rspec/RepeatedExample

      it 'uninstalls with no errors' do
        set_hieradata_on(host, { 'haveged::package_ensure' => 'absent' })
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'is not installed' do
        on(host, 'puppet resource package haveged') do
          expect(stdout).to match(%r{ensure\s*=> 'purged'})
        end
      end

      it 'is not running' do
        on(host, 'puppet resource service haveged') do
          expect(stdout).to match(%r{ensure\s*=> 'stopped'})
          expect(stdout).to match(%r{enable\s*=> 'false'})
        end
      end

      # rubocop:disable Rspec/RepeatedExample
      it 'is idempotent after uninstall' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end
      # rubocop:enable Rspec/RepeatedExample
    end
  end
end

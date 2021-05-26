require 'spec_helper_acceptance'

test_name 'haveged'

describe 'haveged' do
  let(:manifest) {
    <<-EOS
      include 'haveged'
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be installed' do
        on(host, 'puppet resource package haveged') do
          expect(stdout).to_not match(/ensure\s*=> 'absent'/)
        end
      end

      it 'should be stopped if rngd is running and remain stopped after reboot' do
        unless on(host, 'pgrep rngd 2>/dev/null', :accept_all_exit_codes => true).stdout.strip.empty?
          on(host, 'puppet resource service haveged') do
            expect(stdout).to match(/ensure\s*=> 'stopped'/)
            expect(stdout).to match(/enable\s*=> 'false'/)
          end

          host.reboot

          on(host, 'puppet resource service haveged') do
            expect(stdout).to match(/ensure\s*=> 'stopped'/)
            expect(stdout).to match(/enable\s*=> 'false'/)
          end

          on(host, 'pkill rngd')
          apply_manifest_on(host, manifest, :catch_failures => true)
        end
      end

      it 'should be running' do
        on(host, 'puppet resource service haveged') do
          expect(stdout).to match(/ensure\s*=> 'running'/)
          expect(stdout).to match(/enable\s*=> 'true'/)
        end
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should uninstall with no errors' do
        set_hieradata_on(host, { 'haveged::package_ensure' => 'absent' })
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should not be installed' do
        on(host, 'puppet resource package haveged') do
          expect(stdout).to match(/ensure\s*=> 'purged'/)
        end
      end

      it 'should not be running' do
        on(host, 'puppet resource service haveged') do
          expect(stdout).to match(/ensure\s*=> 'stopped'/)
          expect(stdout).to match(/enable\s*=> 'false'/)
        end
      end

      it 'should be idempotent after uninstall' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end
    end
  end
end

require 'spec_helper'

describe 'haveged::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os} with default parameters" do
      let :facts  do
        os_facts
      end

      context 'with default parameters' do
        let(:expected_ensure) do
          facts[:os][:family] == 'RedHat' && facts[:os][:release][:major].to_i < 8 ? 'running' : 'stopped'
        end

        let(:expected_enable) do
          facts[:os][:family] == 'RedHat' && facts[:os][:release][:major].to_i < 8 ? true : 'mask'
        end
        it {
          is_expected.to contain_service('haveged')
            .with_ensure(expected_ensure)
            .with_enable(expected_enable)
        }

        context 'with rngd running' do
          let :facts do
            os_facts.merge({
              :haveged__rngd_enabled => true
            })
          end

          it {
            is_expected.to contain_service('haveged')
              .with_ensure('stopped')
              .with_enable('mask')
          }

          context 'with haveged forced' do
            let :params do
              {
                :force_if_rngd_running => true
              }
            end

            it {
              is_expected.to contain_service('haveged')
                .with_ensure('running')
                .with_enable(true)
            }
          end
        end
      end

      context 'with defined parameters' do
        let :params do
          {
            :service_name   => 'foobar',
            :service_enable => true,
            :service_ensure => 'running',
            :force_if_rngd_running => true
          }
        end

        it {
          is_expected.to contain_service(params[:service_name])
            .with_ensure(params[:service_ensure])
            .with_enable(params[:service_enable])
        }
      end
    end
  end
end

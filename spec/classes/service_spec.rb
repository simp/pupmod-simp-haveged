require 'spec_helper'

describe 'haveged::service' do
  on_supported_os.each do |os, os_facts|
    let :facts  do
      os_facts
    end

    context 'with default parameters' do
      it {
        is_expected.to contain_service('haveged')
          .with_ensure('running')
          .with_enable(true)
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
            .with_enable(false)
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
          :service_ensure => 'running'
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

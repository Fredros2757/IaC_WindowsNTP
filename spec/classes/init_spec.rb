require 'spec_helper'

describe 'windowstime' do
  on_supported_os.each do |os, _os_facts|
    context "on #{os}" do
      let(:facts) { { 'osfamily' => 'windows', 'operatingsystemrelease' => "Server #{os}", 'operatingsystem' => 'windows' } }

      context 'With default parameters' do
        it { is_expected.to contain_class('windowstime::config') }
        it { is_expected.to contain_class('windowstime::service') }
      end
      context 'contain service w32tm' do
        it {
          is_expected.to contain_service('w32time').with(
            'ensure' => 'running',
            'enable' => 'true',
          )
        }
      end
      context 'Sets timezone' do
        let(:params) { { timezone: 'UTC' } }

        it {
          is_expected.to contain_exec('Set timezone').with(
            'command' => 'tzutil /s UTC',
            'provider' => 'powershell',
            'path' => 'c:/windows/system32',
            'logoutput' => true,
          )
        }
      end
      context 'Sets time culture' do
        let(:params) { { timeculture: 'en-US' } }

        it {
          is_expected.to contain_exec('Set time culture').with(
            'command' => 'Set-Culture en-US',
            'provider' => 'powershell',
            'path' => 'c:/windows/system32',
          )
        }
      end
      context 'enables logging' do
        let(:params) { { logging: true, debugpath: 'C:\Windows\Temp\w32tmdebug.log', debugsize: 100_000_00, debugentryfirst: 0, debugentrylast: 300 } }

        it {
          is_expected.to contain_exec('Enabling debug log').with(
            'command' => 'w32tm /debug /enable /file:C:\\Windows\\Temp\\w32tmdebug.log /size:10000000 /entries:0-300',
            'provider' => 'powershell',
            'path' => 'c:/windows/system32',
          )
        }
      end
      context 'disables logging' do
        let(:params) { { logging: false } }

        it {
          is_expected.to contain_exec('Disabling debug log').with(
            'command' => 'w32tm /debug /disable',
            'provider' => 'powershell',
            'path' => 'c:/windows/system32',
          )
        }
      end
      it { is_expected.to compile }
    end
  end
end

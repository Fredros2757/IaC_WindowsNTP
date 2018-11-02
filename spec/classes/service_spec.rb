require 'spec_helper'

describe 'windowstime::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          'windowstime::service_ensure' => 'running',
        }
      end

      it { is_expected.to compile }
    end
  end
end

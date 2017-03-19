require 'spec_helper'

describe 'CPU数' do
  describe command("lscpu | grep 'CPU(s):'| grep -v NUMA") do
    its(:stdout) { should match /#{property[:server_cpu]}/ }
  end
end

describe 'ポート番号チェック' do
  describe port(80) do
    it { should be_listening }
  end
end

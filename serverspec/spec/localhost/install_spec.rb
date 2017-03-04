require 'spec_helper'

describe 'テストケース1' do
  describe file('/var/www/html/index.html') do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
  end
end

describe 'テストケース2' do
  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end
end

describe 'テストケース3' do
  describe port(80) do
    it { should be_listening }
  end
end



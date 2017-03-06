require 'spec_helper'

describe '設定ファイルプロパティ確認' do
  describe file('/var/www/html/index.html') do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
  end
end

describe 'サービス確認' do
  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end
end

describe 'ポート番号チェック' do
  describe port(80) do
    it { should be_listening }
  end
end

describe '設定ファイル内容確認' do
  describe file('/etc/httpd/conf/httpd.conf') do
    its(:content) { should match /^ServerName www.example.jp/ }
  end
end

describe '設定ファイルチェックサム確認' do
  describe file('/var/www/html/index.html') do
    its(:md5sum) { should eq '35435ea447c19f0ea5ef971837ab9ced' }
  end
end

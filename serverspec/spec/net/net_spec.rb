require 'spec_helper'

describe 'ポート番号チェック' do
  describe port(80) do
    it { should be_listening }
  end
end

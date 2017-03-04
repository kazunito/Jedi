require 'rspec/core/formatters/documentation_formatter'
require 'specinfra'
require 'serverspec/version'
require 'serverspec/type/base'
require 'serverspec/type/command'
require 'fileutils'

class ServerspecDebugFormatter < RSpec::Core::Formatters::DocumentationFormatter
  RSpec::Core::Formatters.register self, :example_group_started,
                                   :example_passed, :example_pending, :example_failed

  def initialize(output)
    super
    @seq = 0
  end

  def example_group_started(notification)
    @indent = 2 * (@group_level + 2)
    @seq = 0 if @group_level == 0
    super
  end

  def example_passed(notification)
    super
    puts_evidence(notification.example)
  end

  def example_pending(notification)
    super
    puts_evidence(notification.example)
  end

  def example_failed(notification)
    super
    puts_evidence(notification.example, notification.exception)
  end

  def puts_evidence(example, exception=nil)
    # 以下のように、トップレベルに結果ディレクトリ名として使う名称を指定する前提
    # describe "テストケース1" do
    #   describe command('hostname') do
    #     its(:stdout) { should ... }
    #   end
    # end
    name = example.example_group.top_level_description

    # 出力先ディレクトリを {ホスト名}/{テスト名}/{連番} で作成
    host = ENV['TARGET_HOST'] || Specinfra.configuration.host
    @seq += 1
    d = "audit/#{host}/#{name}/#{@seq}"
    FileUtils.mkdir_p(d)

    # 実行内容をファイル出力
    Dir.chdir(d) do

      # 実行コマンド
      puts ' ' * @indent + '-- command'
      puts ' ' * @indent + example.metadata[:command]
      File.write('command.txt', example.metadata[:command])

      # 標準出力
      if example.metadata[:stdout]
        puts ' ' * @indent + '-- stdout'
        example.metadata[:stdout].lines do |line|
          puts ' ' * @indent + line
        end
      end
      File.write('stdout.txt', example.metadata[:stdout]) if example.metadata[:stdout]

      # RSpecのエラーメッセージ
      if exception
        puts ' ' * @indent + '-- exception'
        exception.message.lines do |line|
          puts ' ' * @indent + line
        end
      end
      File.open('exception.txt', 'w') {|f| f.puts exception.message } if exception

      # 標準エラー出力と終了ステータス（commandリソースのみ）
      resource = example.metadata[:described_class]
      if resource.kind_of? Serverspec::Type::Command
        unless resource.stderr.to_s.empty?
          puts ' ' * @indent + '-- stderr'
          resource.stderr.lines do |line|
            puts ' ' * @indent + line
          end
        end
        puts ' ' * @indent + '-- exit status'
        puts ' ' * @indent + resource.exit_status.to_s
        File.write('stderr.txt', resource.stderr) unless resource.stderr.to_s.empty?
        File.write('exit_status.txt', resource.exit_status)
      end
    end
  end
end

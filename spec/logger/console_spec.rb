# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

module Backup
describe Logger::Console do
  let(:timestamp) { Time.now.strftime("%Y/%m/%d %H:%M:%S") }

  before do
    Logger::Logfile.any_instance.expects(:log).never
    Logger::Syslog.any_instance.expects(:log).never
    Logger.configure do
      logfile.enabled = false
      syslog.enabled = false
      console.quiet = false
    end
  end

  describe 'console logger configuration' do
    it 'may be disabled via Logger.configure' do
      Logger.configure do
        console.quiet = true
      end
      Logger.start!

      Logger::Console.any_instance.expects(:log).never
      Logger.info 'message'
    end

    it 'may be forced enabled via the command line' do
      Logger.configure do
        # --no-quiet should set this to nil
        console.quiet = nil
      end
      Logger.configure do
        # attempt to disable once set to nil will be ignored
        console.quiet = true
      end
      Logger.start!

      Logger::Console.any_instance.expects(:log)
      Logger.info 'message'
    end
  end

  describe 'console logger usage' do
    before { Logger.start! }

    context 'when sending an :info message' do
      it 'sends colorized, formatted message to $stdout' do
        $stderr.expects(:puts).never
        Timecop.freeze do
          $stdout.expects(:puts).with([
            "\e[32m[#{ timestamp }][info] message line one\e[0m",
            "\e[32m[#{ timestamp }][info] message line two\e[0m"
          ])
          Logger.info "message line one\nmessage line two"
        end
      end
    end

    context 'when sending an :warn message' do
      it 'sends colorized, formatted message to $stderr' do
        $stdout.expects(:puts).never
        Timecop.freeze do
          $stderr.expects(:puts).with([
            "\e[33m[#{ timestamp }][warn] message line one\e[0m",
            "\e[33m[#{ timestamp }][warn] message line two\e[0m"
          ])
          Logger.warn "message line one\nmessage line two"
        end
      end
    end

    context 'when sending an :error message' do
      it 'sends colorized, formatted message to $stderr' do
        $stdout.expects(:puts).never
        Timecop.freeze do
          $stderr.expects(:puts).with([
            "\e[31m[#{ timestamp }][error] message line one\e[0m",
            "\e[31m[#{ timestamp }][error] message line two\e[0m"
          ])
          Logger.error "message line one\nmessage line two"
        end
      end
    end
  end
end
end

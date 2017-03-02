require 'open3'

class OperationLogger
  attr_reader :tag

  def initialize(log: Logger.new($stdout), stdout: nil, stderr: $stderr, log_commands: false)
    log = log.kind_of?(Logger) ? log : Logger.new(log)
    @log = ActiveSupport::TaggedLogging.new(log)

    @stdout = stdout
    @stderr = stderr

    @log_commands = log_commands
  end

  delegate :add, :debug, :<<, :log, :info, :error, :fatal, :unknown, :warn,
           :tagged, to: :@log

  def system(*command_parts, **kwargs)
    log_command(command_parts) if @log_commands

    Open3.popen3(*command_parts, **kwargs) do |stdin, stdout, stderr|
      yield(stdin) if block_given?
      stdin.close_write

      streams = [stdout, stderr]
      until streams.empty?
        ready = IO.select(streams)
        next unless (readables = ready&.first)

        readables.each do |readable|
          data = readable.read_nonblock(1024)
          if readable == stdout
            @stdout&.write data
          elsif readable == stderr
            @stderr&.write data
          end
        rescue ::EOFError
          streams.delete readable
        rescue IO::WaitReadable
          retry
        end
      end
    end
  end

  private

  def log_command(command_parts)
    parts = command_parts.
        drop_while { |part| !part.kind_of?(String) }.
        take_while { |part| part.kind_of?(String) }
    return if parts.empty?

    @log.tagged('CMD') { @log.info command_parts.join(' ') }
  end

  class LogProxy
    attr_reader :target, :tag

    def initialize(target, tag)
      @target = target
      @tag = tag
    end

    def method_missing(meth, *args, &block)
      target.tagged(tag) { target.public_send meth, *args, &block }
    end
  end
end

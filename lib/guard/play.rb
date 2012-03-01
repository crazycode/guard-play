require 'guard'
require 'guard/guard'

module Guard
  class Play < Guard

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      super
      @options = {
          :app_path       => ''
      }.update(options)

      @last_failed  = false
      @app_path = @options[:app_path]
      @notify_title =  @app_path.empty? ? "Play!" : "Play! on #{@app_path}"
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      UI.info "Guard::Play is waiting to run auto-test..."
      run_all
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
      UI.info "Guard::Play is stoped."
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
      run_auto_test("--deps")
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_change(paths)
      run_auto_test()
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_deletion(paths)
      run_auto_test()
    end

    private
    def run_auto_test(opts = "")
      UI.info "Guard::Play runing - play auto-test #{@app_path} #{opts}"

      result = []
      IO.popen("play auto-test #{@app_path} #{opts}") { |output|
        output.each_line { |line|
          if line =~ /(FAILED|errors)/
            result << line
            UI.error line
          else
            puts "#{line}"
          end
        }
      }

      if result.empty?
        UI.info "Guard::Play ALL Tests Passed."
        if @last_failed
          Notifier.notify("All Tests on #{@app_path} are Passed!", :title => @notify_title, :image => :success)
        end
        @last_failed  = false
      else
        @last_failed  = true
        UI.error "Guard::Play Tests Failed!"
        Notifier.notify(result.join("\n"), :title => "#{@notify_title} Test Failed!", :image => :failed)
        throw :task_has_failed
      end
    end
  end

end

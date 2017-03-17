module RuboCop
  module Cop
    module Betterment
      class Timeout < Cop
        MSG = 'Using Timeout.timeout without a custom exception can prevent rescue blocks from executing'

        def_node_matcher :timeout_timeout, <<-END
          (send (const nil :Timeout) :timeout $...)
        END

        def on_send(node)
          timeout_timeout(node) do |args|
            add_offense(node, node.source_range, MSG) if args.length == 1
          end
        end
      end
    end
  end
end

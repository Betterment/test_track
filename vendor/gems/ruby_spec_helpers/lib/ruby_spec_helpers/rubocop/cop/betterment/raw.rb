module RuboCop
  module Cop
    module Betterment
      class Raw < Cop
        MSG = 'Using raw creates the potential for XSS attacks.'

        def on_send(node)
          _receiver, method_name = *node
          return unless method_name == :raw
          add_offense(node, :selector, MSG)
        end
      end
    end
  end
end

module DelegateAttribute
  extend ActiveSupport::Concern

  included do
    class_attribute :reverse_delegate_attribute_map
    self.reverse_delegate_attribute_map = { base: :base }
  end

  module ClassMethods
    def delegate_attribute(*getters) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      opts = getters.extract_options!
      to = opts.delete(:to)
      raise 'You must specify what method/association to delegate to' unless to
      getters.each do |getter|
        opts[getter] ||= getter
      end

      opts.each do |getter, delegate_getter|
        delegate_getter_btc = :"#{delegate_getter}_before_type_cast"
        getter_btc = :"#{getter}_before_type_cast"

        instance_methods = Module.new
        include instance_methods

        instance_methods.module_eval do
          define_method getter do
            send(to).public_send(delegate_getter)
          end

          define_method "#{getter}=" do |val|
            send(to).public_send("#{delegate_getter}=", val)
          end

          define_method getter_btc do
            target = send(to)
            if target.respond_to? delegate_getter_btc
              target.public_send(delegate_getter_btc)
            else
              public_send(getter)
            end
          end
        end

        reverse_delegate_attribute_map[delegate_getter] = getter
      end
    end

    private

    def delegator_error_key(foreign_error_key)
      reverse_delegate_attribute_map[foreign_error_key] || foreign_error_key.to_sym
    end
  end
end

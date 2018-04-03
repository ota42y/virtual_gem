module VirtualGem
  module VirtualGemStubs
    module ClassMethods
      def stubs
        return super if class_variable_get(:@@stubs)

        # add virtual gem
        stubs = super
        stubs_by_name = class_variable_get(:@@stubs_by_name)
        ::VirtualGem.update_virtual_gems(stubs, stubs_by_name)

        stubs
      end
    end

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end
  end
end

class Gem::Specification
  prepend ::VirtualGem::VirtualGemStubs
end

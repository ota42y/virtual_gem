module VirtualGem
  module ExtentLockFileParser
    def initialize(*)
      super
      ::VirtualGem.replace_new_requirements(@specs)
    end
  end
end

class Bundler::LockfileParser
  prepend ::VirtualGem::ExtentLockFileParser
end

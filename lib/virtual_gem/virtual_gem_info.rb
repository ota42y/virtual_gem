module VirtualGem
  class VirtualGemInfo
    attr_accessor :name, :new_version, :original_version

    def initialize(name:, new_version:, original_version:)
      @name = name
      @new_version = new_version
      @original_version = original_version
    end
  end
end

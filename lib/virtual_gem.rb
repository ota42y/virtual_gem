require_relative 'virtual_gem/version'
require_relative 'virtual_gem/virtual_gem_info'
require_relative 'virtual_gem/gem/specification'
require_relative 'virtual_gem/bundler/lock_file_parser'

module VirtualGem
  class << self
    def register_virtual_gem(name:, new_version:, original_version:)
      info = ::VirtualGem::VirtualGemInfo.new(name: name, new_version: new_version, original_version: original_version)

      @virtual_gem_dict ||= Hash.new { |h, k| h[k] = {} }
      @virtual_gem_dict[name][new_version] = info
    end

    # changes = [ { gem_name: ['=< 0.3'] } ]
    def register_requirements_changes(name:, version:, new_requirements:)
      @requirements_changes ||= Hash.new { |h, k| h[k] = {} }
      @requirements_changes[name][version] = new_requirements
    end

    def update_virtual_gems(stubs, stubs_by_name)
      create_virtual_gems(stubs, stubs_by_name)
      update_new_requirements(stubs_by_name)
    end

    def replace_new_requirements(specs)
      return unless @requirements_changes

      dict = specs.group_by(&:name)
      @requirements_changes.each do |name, change_settings|
        gems = dict[name]
        next unless gems

        versions = gems.map { |g| [g.version.to_s, g] }.to_h
        next if versions.empty?

        replace_requirements(versions, change_settings)
      end
    end

    private

      def update_new_requirements(stubs_by_name)
        return unless @requirements_changes

        @requirements_changes.each do |name, change_settings|
          gems = stubs_by_name[name]
          next unless gems

          versions = gems.map { |g| [g.version.to_s, g] }.to_h
          next if versions.empty?

          update_requirements(versions, change_settings)
        end
      end

      def create_virtual_gems(stubs, stubs_by_name)
        return unless @virtual_gem_dict

        @virtual_gem_dict.each do |name, info_list|
          gems = stubs_by_name[name]
          versions = build_gem_version_dict(gems)
          next unless versions

          new_gems = info_list.map { |_, info| create_from_info(versions, info) }.compact

          stubs.concat new_gems
          gems.concat new_gems
        end
      end

      def build_gem_version_dict(gems)
        return nil unless gems
        return nil if gems.empty?

        gems.map { |g| [g.version.to_s, g] }.to_h
      end

      def update_requirements(versions, settings)
        settings.each do |version, new_requirements|
          gem = versions[version]
          next unless gem # not found replaced gem
          dependencies_map = gem.to_spec.dependencies.map { |d| [d.name, d] }.to_h

          new_requirements.each do |name, requirements|
            dependency = dependencies_map[name.to_s]
            dependency.instance_variable_set(:@requirement, ::Gem::Requirement.new(requirements)) if dependency
          end
        end
      end

      def replace_requirements(versions, settings)
        settings.each do |version, new_requirements|
          gem = versions[version]
          next unless gem # not found replaced gem

          dependencies_map = gem.dependencies.map { |d| [d.name, d] }.to_h

          new_requirements.each do |name, requirements|
            dependency = dependencies_map[name.to_s]
            dependency.instance_variable_set(:@requirement, ::Gem::Requirement.new(requirements)) if dependency
          end
        end
      end

      def create_from_info(versions, info)
        version = info.original_version
        original_gem = versions[version]
        return nil unless original_gem

        virtual_gem = Gem::StubSpecification.gemspec_stub(original_gem.loaded_from, original_gem.base_dir, original_gem.gems_dir)
        raise 'virtual gem error' unless virtual_gem.valid? # failed..bug?

        data = virtual_gem.instance_variable_get(:@data)
        data.instance_variable_set(:@version, ::Gem::Version.new(info.new_version))

        virtual_gem
      end
  end
end

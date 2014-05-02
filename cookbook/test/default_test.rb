require 'minitest/autorun'
require 'chef'


#
# Shamelessly copy from sethvargo/chefspec
#
class Chef
  module RemoveExistingLWRP
    def self.extended(klass)
      class << klass
        alias_method :build_from_file_without_removal, :build_from_file
        alias_method :build_from_file, :build_from_file_with_removal
      end
    end

    def build_from_file_with_removal(cookbook_name, filename, run_context)
      provider_name = filename_to_qualified_string(cookbook_name, filename)
      class_name    = convert_to_class_name(provider_name)

      remove_existing_lwrp(class_name)
      build_from_file_without_removal(cookbook_name, filename, run_context)
    end

    def remove_existing_lwrp(class_name)
      [self, superclass].each do |resource_holder|
        look_in_parents = false
        if resource_holder.const_defined?(class_name, look_in_parents)
          resource_holder.send(:remove_const, class_name)
        end
      end
    end
  end

  class Resource::LWRPBase
    extend RemoveExistingLWRP
  end

  class Provider::LWRPBase
    extend RemoveExistingLWRP
  end

  class RunContext
    def load_dependencies recipe_name
      rl = Struct.new(:recipes).new([recipe_name])
      @cookbook_compiler = CookbookCompiler.new self, rl, @events
      compile_libraries
      compile_attributes
      compile_lwrps
      compile_resource_definitions
      self
    end

    %w(libraries attributes lwrps resource_definitions).each do |m|
      method = "compile_#{m}"
      define_method method do
        @cookbook_compiler.send method
      end
    end
  end
end

class FakeEvent
  def method_missing m, *args
  end
end

module AspnetSkeleton; end
class AspnetSkeleton::DefaultTest <  Minitest::Test

  def setup
    context = build_context '../packages/cookbooks' do |n|
      ENV['WINDRIVE'] = 'c:'
      ENV['SYSTEMDRIVE'] = 'c:'
      n.automatic['platform'] = 'windows'
      n.automatic['platform_version'] = '2012_r2'
      n.automatic['windows']['feature_provider'] = 'dism'
    end
    
    context.load_dependencies 'aspnet_skeleton::default'

    context.load_recipe 'aspnet_skeleton::default'
    @context = context
  end

  def test_installs_iis
    assert_includes @context.loaded_recipes, 'iis::default'
  end

  def test_removes_the_default_iis_site
    assert_includes @context.loaded_recipes, 'iis::remove_default_site'
  end

  %w(NetFx4Extended-ASPNET45 IIS-NetFxExtensibility45 IIS-ASPNET45).each do |dep|
    define_method "test_installs_aspnet45_dependency_#{dep}" do
      assert_installs "windows_feature[#{dep}]", @context
    end
  end

  def test_installs_aspnet45_dependency_isapi
    assert_includes @context.loaded_recipes, 'iis::mod_isapi'
  end

  def assert_installs name, context
    resource = context.resource_collection.find(name)
    assert_includes resource.action, :install, "Not installed. #{resource.to_s} performed #{resource.action}"
  rescue Chef::Exceptions::ResourceNotFound => e
    flunk e.to_s
  end

  private
  def build_context cookbook_path
    repo = Chef::CookbookLoader.new cookbook_path
    repo.load_cookbooks

    n = Chef::Node.new
    n.automatic['recipes'] = []
    yield n
    cl = Chef::CookbookCollection.new repo

    Chef::RunContext.new n, cl, FakeEvent.new
  end
end

require 'minitest/autorun'
require 'chef'
require '../packages/cookbooks/windows/libraries/windows_helper.rb'
require '../packages/cookbooks/windows/libraries/feature_base.rb'

Chef::Resource::LWRPBase.build_from_file "windows", "../packages/cookbooks/windows/resources/feature.rb", nil
Chef::Provider::LWRPBase.build_from_file "windows", "../packages/cookbooks/windows/providers/feature_dism.rb", nil
Chef::Resource::LWRPBase.build_from_file "windows", "../packages/cookbooks/windows/resources/zipfile.rb", nil
Chef::Provider::LWRPBase.build_from_file "windows", "../packages/cookbooks/windows/providers/zipfile.rb", nil
Chef::Resource::LWRPBase.build_from_file "iis", "../packages/cookbooks/iis/resources/pool.rb", nil
Chef::Provider::LWRPBase.build_from_file "iis", "../packages/cookbooks/iis/providers/pool.rb", nil
Chef::Resource::LWRPBase.build_from_file "iis", "../packages/cookbooks/iis/resources/site.rb", nil
Chef::Provider::LWRPBase.build_from_file "iis", "../packages/cookbooks/iis/providers/site.rb", nil

class IsolatedTest <  Minitest::Test
  class FakeCollection
    attr_reader :resources

    def initialize
      @resources = {}
    end

    def lookup resource
      unless @resources[resource]
        raise Chef::Exceptions::ResourceNotFound
      end
      @resources[resource]
    end

    def insert resource
      @resources[resource.to_s] = resource
    end

    def validate_lookup_spec! resource
      
    end

    def find resource
      lookup resource
    end
  end
  class FakeContext
    attr_reader :node

    def initialize
      @node = Chef::Node.new
      @node.automatic['platform'] = 'windows'
      @node.automatic['platform_version'] = '2012_r2'
      @node.automatic['windows']['feature_provider'] = 'dism'
      @node.default['iis']['docroot'] = 'foo'
      @resource_collection = FakeCollection.new
    end

    def include_recipe name
      
    end

    def definitions
      {}
    end

    def resource_collection
      @resource_collection
    end

    def notifies_delayed resource
      
    end
  end

  def build_node
    FakeNode.new('windows', '2012_r2')
  end

  def test_default
    c = FakeContext.new
    r = Chef::Recipe.new 'aspnet_skeleton', 'default', c
    r.from_file 'recipes/default.rb'

    assert_adds r.resources('iis_pool[skeleton_pool]')
  end

  def assert_adds resource
    assert_includes resource.action, :add, "Not added. #{resource.to_s} performed #{resource.action}"
  end

end

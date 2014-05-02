#
# Cookbook Name:: aspnet_skeleton
# Recipe:: default
#
# Copyright (C) 2014 Allan Espinosa
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See
# the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "iis::default"
include_recipe "iis::mod_isapi"
include_recipe "iis::remove_default_site"

aspnet_dependencies = %w(NetFx4Extended-ASPNET45 IIS-NetFxExtensibility45 IIS-ASPNET45)
aspnet_dependencies.each do |feature|
  windows_feature feature do
    action :install
  end
end

app_pool = iis_pool "skeleton_pool" do
  runtime_version "4.0"
  pipeline_mode :Integrated
  action [:add, :config, :stop]
end

app_root = directory File.join(node["iis"]["docroot"], "skeleton_app") do
  recursive true
  action :create
end

iis_site "skeleton_app" do
  path app_root.path
  application_pool app_pool.name
  action [:add, :start]
end

windows_zipfile app_root.path do
  source "http://192.168.11.4:8000/skeleton.zip"
  checksum "5ce50ed60c26063925d16e22f08f514735df0db96a383cf338dbaad17477b0b0"
  notifies :start, "iis_pool[skeleton_pool]"
end

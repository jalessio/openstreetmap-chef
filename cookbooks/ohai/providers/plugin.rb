#
# Cookbook Name:: ohai
# Provider:: ohai_plugin
#
# Copyright 2015, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  ohai new_resource.name do
    action :nothing
  end

  template plugin_path do
    source new_resource.template
    owner "root"
    group "root"
    mode 0644
    notifies :reload, "ohai[#{new_resource.name}]"
  end
end

action :delete do
  template plugin_path do
    action :delete
  end
end

def plugin_path
  "/etc/chef/ohai/#{new_resource.name}.rb"
end

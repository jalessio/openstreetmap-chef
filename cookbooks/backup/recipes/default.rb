#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2013, OpenStreetMap Foundation
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

package "perl"
package "libdate-calc-perl"

directory "/store/backup" do
  owner "osmbackup"
  group "osmbackup"
  mode 0o2755
end

cookbook_file "/usr/local/bin/expire-backups" do
  owner "root"
  group "root"
  mode 0o755
end

template "/etc/cron.daily/expire-backups" do
  source "expire.cron.erb"
  owner "root"
  group "root"
  mode 0o755
end

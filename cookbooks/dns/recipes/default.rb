#
# Cookbook:: dns
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "git"
include_recipe "apache"

geoservers = search(:node, "roles:geodns").collect(&:name).sort

passwords = data_bag_item("dns", "passwords")

package %w[
  make
  parallel
  rsync
  perl
  libxml-treebuilder-perl
  libxml-writer-perl
  libyaml-perl
  libwww-perl
  libjson-xs-perl
]

remote_file "/usr/local/bin/dnscontrol" do
  action :create
  source "https://github.com/StackExchange/dnscontrol/releases/download/v2.10.0/dnscontrol-Linux"
  owner "root"
  group "root"
  mode 0o755
end

directory "/srv/dns.openstreetmap.org" do
  owner "root"
  group "root"
  mode 0o755
end

remote_directory "/srv/dns.openstreetmap.org/html" do
  source "html"
  owner "root"
  group "root"
  mode 0o755
  files_owner "root"
  files_group "root"
  files_mode 0o644
end

zones = []

Dir.glob("/var/lib/dns/json/*.json").each do |kmlfile|
  zone = File.basename(kmlfile, ".json")

  template "/srv/dns.openstreetmap.org/html/#{zone}.html" do
    source "zone.html.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :zone => zone
  end

  zones.push(zone)
end

template "/srv/dns.openstreetmap.org/html/index.html" do
  source "index.html.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :zones => zones
end

ssl_certificate "dns.openstreetmap.org" do
  domains ["dns.openstreetmap.org", "dns.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "dns.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/dns.openstreetmap.org"
  variables :aliases => ["dns.osm.org"]
end

template "/usr/local/bin/dns-update" do
  source "dns-update.erb"
  owner "root"
  group "git"
  mode 0o750
  variables :passwords => passwords, :geoservers => geoservers
end

execute "dns-update" do
  action :nothing
  command "/usr/local/bin/dns-update"
  user "git"
  group "git"
end

directory "/var/lib/dns" do
  owner "git"
  group "git"
  mode 0o2775
  notifies :run, "execute[dns-update]"
end

template "/var/lib/dns/creds.json" do
  source "creds.json.erb"
  owner "git"
  group "git"
  mode 0o440
  variables :passwords => passwords
end

cookbook_file "#{node[:dns][:repository]}/hooks/post-receive" do
  source "post-receive"
  owner "git"
  group "git"
  mode 0o750
end

template "/usr/local/bin/dns-check" do
  source "dns-check.erb"
  owner "root"
  group "git"
  mode 0o750
  variables :passwords => passwords, :geoservers => geoservers
end

template "/etc/cron.d/dns" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0o644
end

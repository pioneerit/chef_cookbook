#
# Cookbook Name:: bind 
# Recipe:: default
#
# Copyright 2011, Gerald L. Hevener, Jr, M.S.
# Copyright 2011, Eric G. Wolfe
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

# Read ACL objects from data bag.
# These will be passed to the named.options template
if Chef::Config['solo']
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  search(:bind, "role:#{node['bind']['acl-role']}") do |acl|
    node['bind']['acls'] << acl
  end
end

# Install required packages
node['bind']['packages'].each do |bind_pkg|
  package bind_pkg
end

[ node['bind']['sysconfdir'], node['bind']['vardir'] ].each do |named_dir|
  directory named_dir do
    owner "named"
    group "named"
    mode 0750
  end
end

# Create /var/named subdirectories
%w[ data master slaves ].each do |subdir|
  directory "#{node['bind']['vardir']}/#{subdir}" do
    owner "named"
    group "named"
    mode "0770"
    recursive true
  end
end

# Copy /etc/named files into place.
node['bind']['etc_cookbook_files'].each do |etc_file|
  cookbook_file "#{node['bind']['sysconfdir']}/#{etc_file}" do
    owner "named"
    group "named"
    mode "0644"
  end
end

# Copy /var/named files in place
node['bind']['var_cookbook_files'].each do |var_file|
  cookbook_file "#{node['bind']['vardir']}/#{var_file}" do
    owner "named"
    group "named"
    mode "0644"
  end
end

# Create rndc key file, if it does not exist
execute "rndc-key" do
  command node['bind']['rndc_keygen']
  not_if { File.exists?("/etc/rndc.key") }
end

file "/etc/rndc.key" do
  owner "named"
  group "named"
  mode "0600"
  action :touch
end

# Include zones from external source if set.
unless node['bind']['zonesource'].nil?
  include_recipe "bind::#{node['bind']['zonesource']}2zone"
else
  Chef::Log.warn("No zonesource defined, assuming zone names are defined as override attributes.")
end

service "named" do
  supports :reload => true, :status => true
  action [ :enable, :start ]
end

# Render a template with all our global BIND options and ACLs
template "#{node['bind']['sysconfdir']}/named.options" do
  owner "named"
  group "named"
  mode  "0644"
  variables(
    :bind_acls => node['bind']['acls']
  )
  notifies :reload, "service[named]"
end

# Render our template with role zones, or returned results from
# zonesource recipe
template "/etc/named.conf" do
  owner "named"
  group "named"
  mode 0644
  variables(
    :zones => node['bind']['zones'] 
  )
  notifies :reload, "service[named]"
end

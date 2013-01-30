#
# Cookbook Name:: bacula-dir
# Recipe:: default
#
# Copyright 2010, Scalaxy, Inc.
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

class Chef::Recipe
  include Utils
end

bacula_dir_service = "bacula-dir"

service bacula_dir_service

clients = []
search(:node, "bacula-fd_director:#{node[:hostname]}-dir AND bacula-fd_enabled:true") do |n|
  clients << n
end

clients.each do |n|
  if !n[:'bacula-fd'][:schedule].has_key?(:time)
    n[:'bacula-fd'][:schedule][:time] = get_new_time(clients)
    n.save
  end
end

directory "/var/run/bacula" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template "/etc/bacula/bacula-dir.conf" do
  source "bacula-dir.conf.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :clients => clients
  )
  notifies :restart, resources(:service => bacula_dir_service)
  not_if "ss -n dport = :9103 or dport = :9102 | fgrep ESTAB"
end

# BEGIN Temp while two mgmts. Really slow.

query = "bacula-fd_director:backup00-dir AND bacula-fd_enabled:true"
clients03 = `knife search node "#{query}" -i -c /etc/bacula/chef/knife03.rb`.split("\n")
mgmt03_clients = []
i = 0

clients03.sort.uniq.each do |n|
  attrs = JSON.parse(`knife node show #{n} -a bacula-fd -c /etc/bacula/chef/knife03.rb`, :create_additions => false)
  hostname = JSON.parse(`knife node show #{n} -a hostname -c /etc/bacula/chef/knife03.rb`, :create_additions => false)
  mgmt03_clients[i] = {}
  mgmt03_clients[i]["fqdn"] = n
  mgmt03_clients[i]["hostname"] = hostname["hostname"]
  mgmt03_clients[i]["bacula-fd"] = attrs["bacula-fd"]
  time = i < 50 ? "04:#{i + 10}" : "05:#{i - 40}"
  mgmt03_clients[i]["bacula-fd"]["schedule"]["time"] = time
  i += 1
end

template "/etc/bacula/bacula-dir-mgmt03.conf" do
  source "bacula-dir-mgmt03.conf.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :clients => mgmt03_clients
  )
  notifies :restart, resources(:service => bacula_dir_service)
  not_if "ss -n dport = :9103 or dport = :9102 | fgrep ESTAB"
end

# END Temp while two mgmts

service bacula_dir_service do
  supports :restart => true, :reload => false, :status => true
  action [ :enable, :start ]
end


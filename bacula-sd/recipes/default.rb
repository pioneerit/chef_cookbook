#
# Cookbook Name:: bacula-sd
# Recipe:: default
#
# Copyright 2010, yoursite, Inc.
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

bacula_sd_service = "bacula-sd"

service bacula_sd_service

clients = []
search(:node, "bacula-fd_director:backup00-dir AND bacula-fd_enabled:true") {|n| clients << n}

directory "/var/run/bacula" do
  owner "bacula"
  group "bacula"
  mode "0755"
  action :create
end

clients.each do |client|
  directory "/backup/#{client[:hostname]}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end
end

template "/etc/bacula/bacula-sd.conf" do
  source "bacula-sd.conf.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :clients => clients
  )
  notifies :restart, resources(:service => bacula_sd_service)
  not_if "ss -n sport = :9103 | fgrep ESTAB"
end

# BEGIN Temp while two mgmts. Really slow.

query = "bacula-fd_director:backup00-dir AND bacula-fd_enabled:true"
clients03 = `knife search node "#{query}" -i -c /etc/bacula/chef/knife03.rb`.split("\n")
mgmt03_clients = []
i = 0

clients03.sort.uniq.each do |n|
  hostname = JSON.parse(`knife node show #{n} -a hostname -c /etc/bacula/chef/knife03.rb`, :create_additions => false)
  mgmt03_clients[i] = {}
  mgmt03_clients[i]["hostname"] = hostname["hostname"]
  i += 1

  directory "/backup/#{hostname["hostname"]}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end

end

template "/etc/bacula/bacula-sd-mgmt03.conf" do
  source "bacula-sd-mgmt03.conf.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :clients => mgmt03_clients
  )
  notifies :restart, resources(:service => bacula_sd_service)
  not_if "ss -n sport = :9103 | fgrep ESTAB"
end

# END Temp while two mgmts

service bacula_sd_service do
  supports :restart => true, :reload => false, :status => true
  action [ :enable, :start ]
end

directory "/opt/yoursite/bacula" do
  recursive true
  action :create
end

cookbook_file "/opt/yoursite/bacula/stale-files-check.sh" do
  mode "0755"
end

cron "stale-files-check" do
  hour "14"
  minute "15"
  command "/opt/yoursite/bacula/stale-files-check.sh"
end


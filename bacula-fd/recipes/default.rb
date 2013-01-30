#
# Cookbook Name:: bacula-fd
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

bacula_fd_service = "bacula-fd"

service bacula_fd_service

directory "/etc/bacula" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template "/etc/bacula/bacula-fd.conf" do
  source "bacula-fd.conf.erb"
  owner "root"
  group "root"
  mode 0600
  notifies :restart, resources(:service => bacula_fd_service)
end

case node[:platform]
when "suse"
  package "bacula-client"
when "ubuntu","debian"
  package "bacula-fd" do
    action :upgrade
    options "--force-yes"
  end
end

directory "/var/run/bacula" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

service bacula_fd_service do
  supports :restart => true, :reload => false, :status => true
  action [ :enable, :start ]
end


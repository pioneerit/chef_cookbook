#
# Cookbook Name:: user
# Recipe:: default
#
# Author:: Seth Vargo <sethvargo@gmail.com>
#
# Copyright 2012, Seth Vargo
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

# Don't do anything if we can't search
return Chef::Log.warn('recipe[user] uses search. Chef Solo does not support search!') if Chef::Config[:solo]

# For each user with access to this node, create the account
users = search(node['user']['data_bag'], "nodes:any OR nodes:#{node['fqdn']} OR nodes:#{node['ipaddress']}")
users.each do |user|
  user_account (user['id'] || user['username']) do
    comment      user['comment']        unless user['comment'].nil?
    uid          user['uid']            unless user['uid'].nil?
    gid          user['gid']            unless user['gid'].nil?
    groups       user['groups']         unless user['groups'].nil?
    home         user['home']           unless user['home'].nil?
    shell        user['shell']          unless user['shell'].nil?
    password     user['password']       unless user['password'].nil?
    system       user['system'].to_b    unless user['system'].nil?
    ssh_keys     user['ssh_keys']       unless user['ssh_keys'].nil?
    sudo         user['sudo'].to_b      unless user['sudo'].nil?
    nodes        user['nodes']          unless user['nodes'].nil?
    enabled      user['enabled'].to_b   unless user['enabled'].nil?
  end
end

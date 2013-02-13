#
# Cookbook Name:: user
# Provider:: account
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

# This method is called before the actions, so we can set instance
# variables and configuration setup in here.
def load_current_resource
  banner = "Managed by Chef for #{node['fqdn']}"

  @username     = new_resource.username
  @comment      = new_resource.comment ? "#{new_resource.comment} | #{banner}" : banner
  @uid          = new_resource.uid
  @gid          = new_resource.gid
  @home         = new_resource.home || "#{node['user']['home']}/#{@username}"
  @shell        = new_resource.shell || node['user']['shell']
  @password     = new_resource.password
  @system       = new_resource.system

  @groups       = [new_resource.groups].flatten
  @ssh_keys     = [new_resource.ssh_keys].flatten
  @sudo         = new_resource.sudo
  @nodes        = new_resource.nodes
  @enabled      = new_resource.enabled
end

action :manage do
  # Create the user
  l_username      = @username
  l_comment       = @comment
  l_uid           = @uid
  l_gid           = @gid
  l_home          = @home
  l_shell         = @shell
  l_password      = @password
  l_system        = @system
  l_supports      = @supports

  resource = user @username do
    comment     l_comment
    uid         l_uid
    gid         l_gid unless l_gid.nil?
    home        l_home
    shell       l_shell
    password    l_password unless l_password.nil?
    system      l_system unless l_system.nil?
    supports    :manage_home => true
    action      :nothing
  end
  resource.run_action(:create)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?

  # Lock or unlock the user according to the `enabled` attribute
  resource = user @username do
    action :nothing
  end
  resource.run_action(@enabled ? :unlock : :lock)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?

  configure_groups
  configure_sudo
  configure_ssh
end

private
# Use the first group as the primary_group
def primary_group
  @primary_group ||= @gid || @groups.first
end

# Create each group for this user, and add the user appropriately
def configure_groups
  l_username = @username

  @groups.each do |group_name|
    resource = group group_name do
      members   [l_username]
      append    true
      action    :nothing
    end
    resource.run_action(:create)
    new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
  end
end

# Add the user to the sudoers file.
# If you want more explicit control, use  the sudo cookbook directly.
def configure_sudo
  # Don't do anything if we haven't specified the sudo flag
  return unless @sudo
  l_username = @username

  resource = sudo l_username do
    user        l_username
    commands    ['ALL'] # https://github.com/opscode-cookbooks/sudo/pull/6
    nopasswd    true
    action      :nothing
  end
  resource.run_action(:install)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
end

# Set up ssh access for the user
def configure_ssh
  # Don't setup ssh if they didn't provide any keys
  return unless @ssh_keys
  l_primary_group = primary_group
  l_username = @username
  l_ssh_keys = @ssh_keys

  resource = directory "#{@home}/.ssh" do
    owner       l_username
    group       l_primary_group
    mode        '0700'
    recursive   true
    action      :nothing
  end
  resource.run_action(:create)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?

  resource = template "#{@home}/.ssh/authorized_keys" do
    owner       l_username
    group       l_primary_group
    mode        '0600'
    variables   :ssh_keys => l_ssh_keys
    source      'authorized_keys.erb'
  end
  resource.run_action(:create)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
end

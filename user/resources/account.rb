#
# Cookbook Name:: user
# Resource:: account
#
# Author:: Seth Vargo <sethvargo@gmail.com>
#
# Copyright 2011, Seth Vargo
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

actions :manage
default_action :manage

attribute :username,      :kind_of => String, :name_attribute => true
attribute :comment,       :kind_of => String
attribute :uid,           :kind_of => [Integer, String], :required => true
attribute :gid,           :kind_of => [Integer, String]
attribute :groups,        :kind_of => [Array, String], :default => []
attribute :home,          :kind_of => String
attribute :shell,         :kind_of => String
attribute :password,      :kind_of => String
attribute :system,        :kind_of => [TrueClass, FalseClass], :default => false
attribute :ssh_keys,      :kind_of => [Array, String], :default => []
attribute :sudo,          :kind_of => [TrueClass, FalseClass], :default => false
attribute :nodes,         :kind_of => [Array, String], :default => 'any'
attribute :enabled,       :kind_of => [TrueClass, FalseClass], :default => true

def initialize(*args)
  super
  @action = :manage
end

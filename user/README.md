Chef user cookbook
==================
The Chef `user` cookbook provides and LWRP for creating users. The default recipe also creates users from a data_bag.

Requirements
------------
The platform supports the Chef `user` directive.

Attributes
----------
- `node['user']['home']` - the default path to user's home directory (default: OS default)
- `node['user']['shell']` - the default shell (default: OS default)
- `node['user']['data_bag']` - the name of the data_bag to use (default: `users`)
- `node['user']['ssh_key_name']` - the name of the ssh key (default: `id_rsa`)

Usage
-----
#### Attributes
To use attributes for defining users, create a users data_bag:

```json
// data_bags/users/svargo.json
{
  "id": "svargo",
  "uid": "1000",
  "deploy": "any",
  ssh_keys: [...]
}
```

#### LWRP
Examples using this LWRP:

Basic use, create an account:
```ruby
user_account 'svargo' do
  ssh_keys [ 'ssh-rsa ...' ]
end
```

Create a user, specifying uid, primary group id, groups, ssh_keys, sudo privileges, and a list of nodes to create this user on.
```ruby
user_account 'svargo' do
  comment      'This is a user'
  uid          1234
  gid          4321
  groups       [ 'sysadmin', 'developers' ]
  ssh_keys     [ 'ssh-rsa ...' ]
  sudo         true
  nodes        'any'
end
```

##### LWRP Attributes
<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Example</th>
      <th>Default</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>username</td>
      <td>the username for this user</td>
      <td><tt>svargo</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>comment</td>
      <td>a description for this user</td>
      <td><tt>left Company on 12/12/12</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>uid</td>
      <td>the UNIX uid of this user</td>
      <td><tt>1234</tt></td>
      <td>(varies)</td>
    </tr>
    <tr>
      <td>gid</td>
      <td>the primary group id for this user</td>
      <td><tt>4321</tt></td>
      <td><tt></tt></td>
    </tr>
    <tr>
      <td>groups</td>
      <td>the groups this user should belong to<br><br>if the groups don't yet exist, they will be created</td>
      <td><tt>[ 'sysadmins' ]</tt></td>
      <td><tt>[]</tt></td>
    </tr>
    <tr>
      <td>home</td>
      <td>the path to this user's home directory</td>
      <td><tt>/home/svargo</tt></td>
      <td>(varies based on OS)</td>
    </tr>
    <tr>
      <td>shell</td>
      <td>the shell for this user</td>
      <td><tt>/bin/bash</tt></td>
      <td>(varies based on OS)</td>
    </tr>
    <tr>
      <td>password</td>
      <td>the password for this user<br><br>see the Opscode user docs for more information.</td>
      <td><tt>ajdafk$2902da24</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>system</td>
      <td>create this user as a system account</td>
      <td><tt>true</tt></td>
      <td>false</td>
    </tr>
    <tr>
      <td>ssh_keys</td>
      <td>array of ssh_keys for this user</td>
      <td><tt>[ 'ssh-rsa ...' ]</tt></td>
      <td></td>
    </tr>
    <tr>
      <td>sudo</td>
      <td>give this user sudo rights<br><br>for more control over sudo commands and privileges, check out the [sudo cookbook](https://github.com/opscode-cookbooks/sudo).</td>
      <td><tt>true</tt></td>
      <td>false</td>
    </tr>
    <tr>
      <td>nodes</td>
      <td>array of nodes (IPs or FQDNs) this user should be created on</td>
      <td><tt>[ '1.2.3.4', 'mynode.example.com' ]</tt></td>
      <td>'any'</td>
    </tr>
    <tr>
      <td>enabled</td>
      <td>boolean if this user is enabled<br><br>if the user is not enabled, the account will be `locked` on the server</td>
      <td><tt>false</tt></td>
      <td>true</td>
    </tr>
  </tbody>
</table>

Usage
-----
If you're using [Berkshelf](http://berkshelf.com/), just add `user` to your `Berksfile`:

```ruby
cookbook 'user'
```

Otherwise, install the cookbook from the community site:

    knife cookbook site install user

Have any other cookbooks *depend* on user by editing editing the `metadata.rb` for your cookbook.

```ruby
depends 'user'
```

Once you have the cookbook installed, add it to your node's `run_list` or `role`:

```ruby
"run_list": [
  "recipe[user]"
]
```

Contributing
------------
1. Fork the project
2. Create a feature branch corresponding to you change
3. Commit and test thoroughly
4. Create a Pull Request on github
    - ensure you add a detailed description of your changes

License and Authors
-------------------
- Author:: Seth Vargo (sethvargo@gmail.com)

Copyright 2012, Seth Vargo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

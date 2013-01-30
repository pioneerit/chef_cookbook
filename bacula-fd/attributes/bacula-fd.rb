default[:'bacula-fd'][:service] = "bacula-fd"

default[:'bacula-fd'][:enabled] = true
default[:'bacula-fd'][:director] = "backup00-dir"
default[:'bacula-fd'][:password] = "YourPassword"
default[:'bacula-fd'][:include_files] = ["/etc", "/media/storage00", "/var/spool/cron", "/opt"]
default[:'bacula-fd'][:exclude_files] = ["/media/storage00/var-lib-mysql", "/media/storage00/var-log", "/media/storage00/tmp", "/media/storage00/var-lib-mongodb"]
default[:'bacula-fd'][:client_scripts] = []
default[:'bacula-fd'][:run_scripts] = {}
default[:'bacula-fd'][:checkfilechanges] = "yes"

case platform
when "debian"
  default[:'bacula-fd'][:include_files] |= ["/tmp/dpkg.list", "/var/lib/dpkg/status"]
  default[:'bacula-fd'][:run_scripts][:get_package_list] = {
      :RunsWhen => "Before",
      :RunsOnClient => "yes",
      :FailJobOnError => "no",
      :Command => "\"sh -c \\\"dpkg --get-selections >/tmp/dpkg.list\\\"\""
    }
end

default[:'bacula-fd'][:schedule][:full] = "sun"
default[:'bacula-fd'][:schedule][:incremental] = "mon-sat"

# Attributes cleanup
if node[:'bacula-fd'].has_key?(:schedule_time)
  set[:'bacula-fd'][:schedule][:time] = node[:'bacula-fd'][:schedule_time]
  @normal_attrs[:'bacula-fd'].delete(:schedule_time)
end  


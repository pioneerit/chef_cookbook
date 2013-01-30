require 'date'

module Utils
  def middle_of_max(array_in)
    
    result_tmp = array_in.reduce([0, 0, array_in[0]]) do |(interval_beginning, interval_max, previous), i|
      diff = i - previous
      diff >= interval_max ? [previous, diff, i] : [interval_beginning, interval_max, i]
    end

    interval_beginning, interval_max = result_tmp[0, 2]

    interval_beginning + (interval_max / 2)
  end


  def get_new_time(clients)

    times = []
    clients.each do |n|
      if n[:'bacula-fd'][:schedule].has_key?('time')
        times << DateTime.parse(n[:'bacula-fd'][:schedule][:time])
      end
    end

    valid_time_begin = DateTime.parse(node[:'bacula-dir'][:auto_time_begin])
    valid_time_end   = DateTime.parse(node[:'bacula-dir'][:auto_time_end])

    times = times.find_all{|i| (i > valid_time_begin) && (i < valid_time_end)}
    times = [valid_time_begin] + times + [valid_time_end]
    times = times.sort

    new_time = middle_of_max(times)

    "%02d:%02d" % [new_time.hour, new_time.min]
  end
end

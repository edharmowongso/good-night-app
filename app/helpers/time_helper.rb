module TimeHelper
  def get_current_time(time_zone = 'UTC')
    Time.current.in_time_zone(time_zone).strftime('%Y-%m-%d %H:%M:%S')
  end

  def get_current_time_without_str(time_zone = 'UTC')
    Time.current.in_time_zone(time_zone)
  end

  def get_time_plus_duration_periods(time_zone = 'UTC', duration)
    duration_time = duration.hours
    time_after_plus_x_period = Time.current.in_time_zone(time_zone) + duration_time
    
    return time_after_plus_x_period.strftime('%Y-%m-%d %H:%M:%S')
  end

  def convert_string_period_into_time_period(duration_str)
    amount, unit = duration_str.split
    period = amount.to_i.send(unit.singularize)

    return period
  end

  def get_new_time_plus_period(time_zone = 'UTC', additional_period)
    new_time = Time.current.in_time_zone(time_zone) + additional_period

    return new_time.strftime('%Y-%m-%d %H:%M:%S')
  end

  def convert_unix_timestamp(timestamp)
    converted_time = Time.at(timestamp)
    formatted_time = converted_time.strftime("%A, %-d %b %Y %H:%M:%S")

    formatted_time
  end

  def convert_local_time(datetime_str, time_zone = 'UTC')
    converted_datetime_str = datetime_str.sub('.',':')
    Time.strptime(converted_datetime_str, "%Y-%m-%d %H:%M")
      .in_time_zone(time_zone)
  end
end

##
# Helper methods for application_controller
module ApplicationHelpers
  API_BASE_URI = 'http://cadetdynamo.herokuapp.com'
  API_VER = '/api/v3/'

  def current_page?(path = ' ')
    path_info = request.path_info
    path_info += ' ' if path_info == '/'
    request_path = path_info.split '/'
    request_path[1] == path
  end

  def cadet_api_url(resource)
    URI.join(API_BASE_URI, API_VER, resource).to_s
  end

  def date_in_open_range?(date, from: nil, til: nil)
    from_check = from ? from < date : true
    til_check = til ? date < til : true

    from_check && til_check
  end

  def date_count(badges, from: nil, til: nil)
    dates = Hash.new(0)
    badges.each { |badge| dates[Date.parse(badge['date'])] += 1 }
    from ||= dates.keys.min - 1
    til ||= dates.keys.max + 1

    (from..til).each do |date|
      dates[date] = 0 if (dates[date] == 0) # if date in range is not yet set
    end
    dates
  end

  def array_strip(str_arr)
    str_arr.map(&:strip).reject(&:empty?)
  end

  def error_send(url, msg)
    flash[:error] = msg
    redirect url
    halt 303        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  end
end

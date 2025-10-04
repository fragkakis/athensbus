class NormalScheduleSyncer < BaseScheduleSyncer

  def process
    Rails.logger.info("Syncing normal schedule for line with id: #{line.id}")

    sync_normal_schedule

    Rails.logger.info("Synced normal schedule for line with id: #{line.id}")
  end

  private

  def sync_normal_schedule
    r = RestClient::Request.execute(
      method: :get,
      url: "http://telematics.oasa.gr/api/?act=getScheduleDaysMasterline&p1=#{line.code}",
      timeout: 5)

    types_of_schedule = JSON.parse(r.body).presence || []

    sunday_code = types_of_schedule.find{|e| e["sdc_descr"].include?("ΚΥΡΙΑΚΗ")}.try("[]", "sdc_code")
    saturday_code = types_of_schedule.find{|e| e["sdc_descr"].include?("ΣΑΒΒΑΤΟ")}.try("[]", "sdc_code")
    weekday_code = types_of_schedule.find{|e| e["sdc_descr"].include?("ΚΑΘΗΜΕΡΙΝΗ")}["sdc_code"]

    today_code = if Date.current.sunday?
                   sunday_code || weekday_code
                 elsif Date.current.saturday?
                   saturday_code || weekday_code
                 else
                   weekday_code
                 end
    r = RestClient::Request.execute(
      method: :get,
      url: "http://telematics.oasa.gr/api/?act=getSchedLines&p1=#{CGI.escape(line.line_id)}&p2=#{today_code}&p3=#{line.code}",
      timeout: 5)
    normal_schedule = JSON.parse(r.body).presence || []

    come_departure_times = extract_departure_times(normal_schedule["come"])
    come_routes.each do |route|
      upsert_schedule(route, Schedule::NORMAL, come_departure_times)
    end

    go_departure_times = extract_departure_times(normal_schedule["go"])
    go_routes.each do |route|
      upsert_schedule(route, Schedule::NORMAL, go_departure_times)
    end
  end
end

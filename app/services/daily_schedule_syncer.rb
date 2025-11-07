class DailyScheduleSyncer < BaseScheduleSyncer

  def process
    Rails.logger.info("Syncing schedules for line with id: #{line.id}")

    sync_daily_schedule

    Rails.logger.info("Synced schedules for line with id: #{line.id}")
  end

  private

  def sync_daily_schedule
    r = RestClient::Request.execute(
      method: :get,
      url: "#{TELEMATICS_BASE_URL}/api/?act=getDailySchedule&line_code=#{line.code}",
      timeout: 5)

    daily_schedule = JSON.parse(r.body).presence || []

    go_departure_times = extract_departure_times_for_go(daily_schedule["go"])
    go_routes.each do |route|
      upsert_schedule(route, Schedule::DAILY, go_departure_times)
    end

    come_departure_times = extract_departure_times_for_come(daily_schedule["come"])
    come_routes.each do |route|
      upsert_schedule(route, Schedule::DAILY, come_departure_times)
    end

  end

end

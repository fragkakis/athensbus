module Schedules
  module Athens
    class NormalScheduleSyncer < BaseScheduleSyncer

      def process
        Rails.logger.info("Syncing normal schedule for line with id: #{line.id}")

        sync_normal_schedule

        Rails.logger.info("Synced normal schedule for line with id: #{line.id}")
      end

      private

      def sync_normal_schedule

        today_code = SdcCodePicker.process(line)

        url = "#{TELEMATICS_BASE_URL}/api/?act=getSchedLines&p1=#{CGI.escape(line.line_id)}&p2=#{today_code}&p3=#{line.code}"
        r = RestClient::Request.execute(
          method: :get,
          url: url,
          timeout: 5)
        normal_schedule = JSON.parse(r.body).presence || []

        go_departure_times = extract_departure_times_for_go(normal_schedule["go"])
        go_routes.each do |route|
          upsert_schedule(route, Schedule::NORMAL, go_departure_times)
        end

        come_departure_times = extract_departure_times_for_come(normal_schedule["come"])
        come_routes.each do |route|
          upsert_schedule(route, Schedule::NORMAL, come_departure_times)
        end
      end

      WEEKDAY_TERMS_WITH_PRIORITY = [
        "ΔΕΥΤΕΡΑ -",
        "ΚΑΘΗΜΕΡΙΝΗ",
        "ΚΑΘΗΜΕΡΙΝH",  # contains an H in english, not a duplicate of the above
        "ΟΛΕΣ"
      ]

      def get_weekday_code(types_of_schedule)
        WEEKDAY_TERMS_WITH_PRIORITY.each do |weekday_term|
          weekday_schedule = types_of_schedule.find do |e|
            e["sdc_descr"].include?(weekday_term)
          end
          if weekday_schedule.present?
            return weekday_schedule["sdc_code"]
          end
        end
        nil
      end
    end
  end
end

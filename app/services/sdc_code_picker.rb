class SdcCodePicker

  def self.process(line)
    r = RestClient::Request.execute(
      method: :get,
      url: "#{TELEMATICS_BASE_URL}/api/?act=getScheduleDaysMasterline&p1=#{line.code}",
      timeout: 5)

    types_of_schedule = JSON.parse(r.body).presence || []

    sunday_code = types_of_schedule.find{|e| e["sdc_descr"].include?("ΚΥΡΙΑΚΗ")}.try("[]", "sdc_code")
    saturday_code = types_of_schedule.find{|e| e["sdc_descr"].include?("ΣΑΒΒΑΤΟ")}.try("[]", "sdc_code")
    friday_code = types_of_schedule.find{|e| e["sdc_descr"].include?("ΠΑΡΑΣΚΕΥΗ")}.try("[]", "sdc_code")

    weekday_code = get_weekday_code(types_of_schedule)

    if Date.current.sunday?
                   sunday_code || weekday_code
                 elsif Date.current.saturday?
                   saturday_code || weekday_code
                 elsif Date.current.friday?
                   friday_code || weekday_code
                 else
                   weekday_code
                 end
  end

  WEEKDAY_TERMS_WITH_PRIORITY = [
    "ΔΕΥΤΕΡΑ -",
    "ΚΑΘΗΜΕΡΙΝΗ",
    "ΚΑΘΗΜΕΡΙΝH",  # contains an H in english, not a duplicate of the above
    "ΟΛΕΣ"
  ]

  def self.get_weekday_code(types_of_schedule)
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

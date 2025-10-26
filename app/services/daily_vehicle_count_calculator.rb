class DailyVehicleCountCalculator
  def self.process(date)
    new(date).process
  end

  def initialize(date)
    @date = date
  end

  def process
    count = Arrival
              .where("DATE(created_at) = ?", date)
              .count("distinct vehicle_id")

    DailyVehicleCount.upsert(
      { date: date, vehicle_count: count },
      unique_by: :date
    )
  end

end

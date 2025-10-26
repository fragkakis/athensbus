class CalculateDailyVehicleCountJob < ApplicationJob
  queue_as :default

  def perform(date = Date.current)
    DailyVehicleCountCalculator.process(date)
  end
end

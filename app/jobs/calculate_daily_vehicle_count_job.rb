class CalculateDailyVehicleCountJob < ApplicationJob
  queue_as :default

  def perform(date = Date.yesterday)
    DailyVehicleCountCalculator.process(date)
  end
end

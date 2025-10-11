class ReportsController < ApplicationController

  def index

  end

  def coverage
    date = params[:date] || Date.current

    sql = <<~SQL
      select l.line_id as line_id,
            l.description as line_description,
            r.description as route_description,
            jsonb_array_length(ds.departure_times) as daily_schedule_count,
            jsonb_array_length(ns.departure_times) as normal_schedule_count,
            rdr.executed_trips as executed_trips
      from routes r
      inner join lines l on l.id = r.line_id
      left outer join schedules ds on ds.route_id = r.id AND ds.type = 'daily' and ds.date = $1
      left outer join schedules ns on ns.route_id = r.id AND ns.type = 'normal' and ns.date = $1
      left outer join route_daily_reports rdr on rdr.route_id = r.id and rdr.date = $1
    SQL

    @results = ActiveRecord::Base.connection.raw_connection.exec_params(sql, [date])
  end
end

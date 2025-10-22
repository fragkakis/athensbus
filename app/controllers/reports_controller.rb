class ReportsController < ApplicationController
  before_action :set_date_range, only: [:estimated_coverage, :daily_vs_normal, :vehicles, :vehicle_count]
  before_action :set_date, only: [:estimated_coverage, :daily_vs_normal, :vehicles]

  def index

  end

  def estimated_coverage

    # Whitelist sortable columns to prevent SQL injection
    sort_column = params[:sort].presence_in(%w[line_id normal_schedule_count executed_trips coverage]) || 'coverage'
    sort_direction = params[:direction].presence_in(%w[asc desc]) || 'desc'

    # Map sort column to actual SQL column/expression
    sort_sql = case sort_column
    when 'line_id'
      'l.line_id'
    when 'normal_schedule_count'
      'jsonb_array_length(ns.departure_times)'
    when 'executed_trips'
      'rdr.executed_trips'
    when 'coverage'
      'coverage'
    end

    sql = <<~SQL
      select l.code as line_code,
            l.line_id as line_id,
            l.description as line_description,
            r.route_id as route_id,
            r.description as route_description,
            jsonb_array_length(ns.departure_times) as normal_schedule_count,
            rdr.executed_trips as executed_trips,
            CASE
              WHEN jsonb_array_length(ns.departure_times) > 0 THEN
                (rdr.executed_trips::float / jsonb_array_length(ns.departure_times)::float * 100)
              ELSE NULL
            END as coverage
      from routes r
      inner join lines l on l.id = r.line_id
      inner join schedules ns on ns.route_id = r.id AND ns.type = 'normal' and ns.date = $1
      inner join route_daily_reports rdr on rdr.route_id = r.id and rdr.date = $1
      where rdr.executed_trips > 0
        and jsonb_array_length(ns.departure_times) > 0
        and (rdr.executed_trips::float / jsonb_array_length(ns.departure_times)::float * 100) <= 100
      order by #{sort_sql} #{sort_direction} nulls last
    SQL

    @results = ActiveRecord::Base.connection.raw_connection.exec_params(sql, [@date])
    @sort_column = sort_column
    @sort_direction = sort_direction
  end

  def daily_vs_normal

    # Whitelist sortable columns to prevent SQL injection
    sort_column = params[:sort].presence_in(%w[line_id normal_schedule_count daily_schedule_count percentage]) || 'percentage'
    sort_direction = params[:direction].presence_in(%w[asc desc]) || 'desc'

    # Map sort column to actual SQL column/expression
    sort_sql = case sort_column
    when 'line_id'
      'l.line_id'
    when 'normal_schedule_count'
      'jsonb_array_length(ns.departure_times)'
    when 'daily_schedule_count'
      'jsonb_array_length(ds.departure_times)'
    when 'percentage'
      'percentage'
    end

    sql = <<~SQL
      select l.code as line_code,
            l.line_id as line_id,
            l.description as line_description,
            r.route_id as route_id,
            r.description as route_description,
            jsonb_array_length(ns.departure_times) as normal_schedule_count,
            jsonb_array_length(ds.departure_times) as daily_schedule_count,
            CASE
              WHEN jsonb_array_length(ns.departure_times) > 0 THEN
                (jsonb_array_length(ds.departure_times)::float / jsonb_array_length(ns.departure_times)::float * 100)
              ELSE NULL
            END as percentage
      from routes r
      inner join lines l on l.id = r.line_id
      inner join schedules ns on ns.route_id = r.id AND ns.type = 'normal' and ns.date = $1
      inner join schedules ds on ds.route_id = r.id AND ds.type = 'daily' and ds.date = $1
      where jsonb_array_length(ns.departure_times) > 0
        and (jsonb_array_length(ds.departure_times)::float / jsonb_array_length(ns.departure_times)::float * 100) <= 100
      order by #{sort_sql} #{sort_direction} nulls last
    SQL

    @results = ActiveRecord::Base.connection.raw_connection.exec_params(sql, [@date])
    @sort_column = sort_column
    @sort_direction = sort_direction
  end

  def vehicles
    # Whitelist sortable columns to prevent SQL injection
    sort_column = params[:sort].presence_in(%w[vehicle_code routes_count]) || 'vehicle_code'
    sort_direction = params[:direction].presence_in(%w[asc desc]) || 'asc'

    # Map sort column to actual SQL column/expression
    sort_sql = case sort_column
    when 'vehicle_code'
      'v.code'
    when 'routes_count'
      'routes_count'
    end

    sql = <<~SQL
      select v.code as vehicle_code,
             string_agg(distinct l.line_id, ', ' order by l.line_id) as lines,
             count(distinct r.id) as routes_count
      from vehicles v
      inner join arrivals a on a.vehicle_id = v.id
      inner join routes r on r.id = a.route_id
      inner join lines l on l.id = r.line_id
      where DATE(a.created_at) = $1
      group by v.code
      order by #{sort_sql} #{sort_direction}
    SQL

    @results = ActiveRecord::Base.connection.raw_connection.exec_params(sql, [@date])
    @total_vehicles = @results.ntuples
    @sort_column = sort_column
    @sort_direction = sort_direction
  end

  def vehicle_count
    # Group arrivals by date and count distinct vehicles per day
    @results = Arrival
      .group("DATE(created_at)")
      .select("DATE(created_at) as date, COUNT(DISTINCT vehicle_id) as vehicle_count")
      .order("DATE(created_at) DESC")
  end

  private

  def set_date_range
    @date_min = Arrival.minimum(:created_at).to_date.to_s
    @date_max = [Date.yesterday, Arrival.maximum(:created_at)].min.to_date.to_s
  end

  def set_date
    @date = params[:date] || Date.yesterday
  end
end

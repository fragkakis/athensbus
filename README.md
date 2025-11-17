# Athens Bus Info

A public transportation tracking and analytics platform for Athens (and Thessaloniki, WIP), Greece. This Rails application synchronizes real-time and scheduled bus data from OASA (Athens Urban Transport Organization) and THESS telematics APIs, providing route statistics, vehicle tracking, and schedule comparisons.

Live at: [athensbus.info](https://athensbus.info)

## Features

- **Real-time Bus Tracking**: Fetch and display live vehicle locations for bus routes
- **Schedule Synchronization**: Sync and store both normal and daily bus schedules
- **Route Analytics**: Generate daily reports with statistics on route coverage and performance
- **Vehicle Count Tracking**: Monitor and calculate daily vehicle counts per route
- **Stop Management**: Automatically sync and geocode bus stop information
- **Multi-City Support**: Support for both Athens and Thessaloniki public transit systems
- **Reporting Dashboard**: View estimated coverage, schedule comparisons, and vehicle statistics
- **Background Job Processing**: Automated data synchronization via Solid Queue

## Tech Stack

- **Rails**: 8.0.1
- **Ruby**: 3.3.5
- **Database**: PostgreSQL (production), SQLite3 (development/test)
- **Job Queue**: Solid Queue with Mission Control interface
- **Cache**: Solid Cache
- **Frontend**: Hotwire (Turbo + Stimulus), Importmap
- **Charts**: Chartkick
- **Deployment**: Kamal (Docker-based deployment)
- **Error Tracking**: Honeybadger
- **Geocoding**: Geocoder gem

## Requirements

- Ruby 3.3.5 or higher
- PostgreSQL (production)
- SQLite3 (development/test)
- Docker (for deployment)

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd oasa
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Database Setup

```bash
# Create and migrate the database
bin/rails db:create
bin/rails db:migrate

# Seed initial data (if applicable)
bin/rails db:seed

# and in a Rails console

r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=webGetLines")
lines = JSON.parse(r.body)

lines.each do |line|
  Populators::Line.populate(line)
end
```

### 4. Configure Environment Variables

Create a `.env` file or set the following environment variables:

```bash
# City configuration
CITY_NAME=athens  # or 'thessaloniki'
TELEMATICS_BASE_URL=http://telematics.oasa.gr  # Athens
# TELEMATICS_BASE_URL=http://oasth.gr/el  # Thessaloniki

# Database (production)
DB_HOST=localhost
DB_PORT=5432
POSTGRES_DB=oasa_production
POSTGRES_USER=oasa
POSTGRES_PASSWORD=your_password

# Error tracking
HONEYBADGER_API_KEY=your_api_key

# Job processing
JOB_CONCURRENCY=6

# Rails
RAILS_MASTER_KEY=your_master_key
```

## Running the Application

### Development Server

```bash
bin/rails server
```

The application will be available at `http://localhost:3000`

### Background Jobs

Start the Solid Queue worker:

```bash
bin/jobs
```

Or run jobs within Puma (development):

```bash
SOLID_QUEUE_IN_PUMA=true bin/rails server
```

### Job Dashboard

Access Mission Control at: `http://localhost:3000/jobs`

## Running Tests

```bash
# Run all tests
bin/rails test

# Run specific test files
bin/rails test test/models/route_test.rb
bin/rails test test/services/schedules/athens/normal_schedule_syncer_test.rb

# Run with coverage
COVERAGE=true bin/rails test
```

## Background Jobs & Scheduled Tasks

The application runs several recurring jobs (configured in `config/recurring.yml`):

- **Sync Stops** (every 5 minutes): Fetches and updates bus stop data
- **Generate Daily Reports** (daily at 00:00): Creates route performance reports
- **Delete Old Data** (daily at 00:00): Cleans up historical data
- **Sync Schedules** (daily at 00:00, 08:00, 23:00): Updates bus schedules
- **Calculate Daily Vehicle Count** (daily at 00:00): Computes vehicle statistics

## Key Services

### Schedule Syncers

- `Schedules::Athens::NormalScheduleSyncer`: Syncs regular schedules from OASA API
- `Schedules::Athens::DailyScheduleSyncer`: Syncs daily variations
- `Schedules::Thessaloniki::NormalScheduleSyncer`: Syncs Thessaloniki schedules

### Data Processing

- `StopSyncer`: Updates bus stop information and geocoding
- `TripExtractor`: Extracts trip data from arrival information
- `TripsCalculator`: Calculates trip statistics
- `DailyVehicleCountCalculator`: Computes daily vehicle counts
- `RouteDailyReports::Creator`: Generates comprehensive route reports

### Populators

- `Populators::Line`: Seeds line data
- `Populators::Route`: Seeds route data

## API Endpoints

### Web Routes

- `GET /` - Lines index page
- `GET /lines` - List all lines
- `GET /routes/:code/stats` - Route statistics page
- `GET /reports` - Reports dashboard
  - `/reports/estimated_coverage` - Coverage reports
  - `/reports/daily_vs_normal` - Schedule comparison
  - `/reports/vehicles` - Vehicle reports
  - `/reports/vehicle_count` - Vehicle count statistics
  - `/reports/stops` - Stop reports
- `GET /about` - About page
- `GET /up` - Health check endpoint

## Deployment

This application uses Kamal for Docker-based deployment.

### Prerequisites

- Docker installed on your deployment server
- Docker Hub account (or other registry)
- Server with SSH access

### Deploy to Production

```bash
# First time setup
bin/kamal setup

# Deploy updates
bin/kamal deploy

# Useful aliases (defined in config/deploy.yml)
bin/kamal console    # Rails console
bin/kamal shell      # Server shell
bin/kamal logs       # Tail logs
bin/kamal dbc        # Database console
```

### Deployment Configuration

- Athens: `config/deploy.yml`
- Thessaloniki: `config/deploy-thess.yml`

## Development Tools

### Code Quality

- **Rubocop**: Ruby style linting (`bundle exec rubocop`)
- **Brakeman**: Security vulnerability scanner (`bundle exec brakeman`)
- **Bullet**: N+1 query detection (automatically enabled in development)

### Git Hooks

Install Lefthook for automated checks:

```bash
bundle exec lefthook install
```

### Debugging

- Use `debug` gem: Add `debugger` in your code
- Web Console: Available in development on error pages
- Mission Control: Monitor jobs at `/jobs`

## Database Schema

Key models:

- **Line**: Bus line (e.g., "X95", "040")
- **Route**: Specific route direction for a line
- **Stop**: Bus stop location
- **RoutesStop**: Join table linking routes to stops in order
- **Schedule**: Bus schedules (normal and daily)
- **Arrival**: Real-time arrival predictions
- **Vehicle**: Vehicle tracking data
- **RouteDailyReport**: Daily analytics per route
- **DailyVehicleCount**: Daily vehicle count statistics

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `bin/rails test`
4. Run linters: `bundle exec rubocop`
5. Commit your changes
6. Push and create a pull request

## License

[Add your license here]

## Contact

For issues and questions, please open an issue on GitHub.

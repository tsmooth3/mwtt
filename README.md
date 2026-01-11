# Mid-Winter Tree Tracker

A Ruby on Rails web application for tracking tree collections by families and seasons, with authentication, goal setting, and comprehensive reporting features.

## Features

- **Authentication**: Email/password and Google OAuth login
- **Family Management**: Create and join families, with admin roles
- **Tree Entry Tracking**: Log tree collections with date and count
- **Seasonal Goals**: Set and track goals per family per season (year)
- **Dashboard**: View family totals, overall totals, and progress charts
- **Leaderboard**: See family rankings by season
- **Charts & Visualization**: Visual progress tracking with Chartkick

## Setup

### Prerequisites

- Ruby 3.4.5 or higher
- PostgreSQL
- Node.js (for Tailwind CSS)

### Installation

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

3. Configure Google OAuth (optional):
   - Create a Google OAuth application at https://console.cloud.google.com/
   - Set environment variables:
     ```bash
     export GOOGLE_CLIENT_ID=your_client_id
     export GOOGLE_CLIENT_SECRET=your_client_secret
     ```

4. Start the server:
   ```bash
   rails server
   ```

   Or use the development script:
   ```bash
   bin/dev
   ```

## Usage

1. Sign up or log in (with email/password or Google)
2. Create or join a family
3. Start logging tree entries
4. Family admins can set season goals
5. View progress on the dashboard and leaderboard

## Models

- **User**: Authentication and user data
- **Family**: Family groups
- **FamilyMembership**: Join table with admin flag
- **Season**: Year-based seasons
- **SeasonGoal**: Goals per family per season
- **TreeEntry**: Individual tree collection entries

## Development

Run tests:
```bash
rails test
```

## License

MIT

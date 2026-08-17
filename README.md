# Mid-Winter Tree Tracker

A Ruby on Rails web application for tracking tree collections by families and seasons, with authentication, goal setting, and comprehensive reporting features.

## Features

- **Authentication**: Email/password and Google OAuth login
- **Family Management**: Create and join families, with admin roles
- **Tree Entry Tracking**: Log what was seen and what was collected, with an optional map pin
- **Shared Hunt Map**: Current-season inventory, cleared and empty checks, plus last year's places as a hint
- **Seasonal Goals**: Set and track a shared bonfire goal per winter season
- **Dashboard**: Family totals, overall totals, a season map, and progress charts
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
- **Season**: Christmas-winter seasons (Dec 1 – Feb 15, labeled by that Christmas)
- **SeasonGoal**: Shared bonfire goal per season
- **Location**: Reusable map pin
- **TreeEntry**: Field report of trees seen and collected

## Development

Run tests:
```bash
rails test
```

## License

MIT

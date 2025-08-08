# Good Night App 🌙

A Ruby on Rails API application for tracking sleep records and following friends' sleep patterns.

## ✨ Features

### Core Sleep Tracking
1. **Clock In/Out System**: Track bedtime and wake time with automatic duration calculation using Asia/Jakarta timezone
2. **Sleep Quality Tracking**: Rate sleep quality (1-5 stars) and add personal notes
3. **Sleep Status Management**: Track sleep records as incomplete, completed, or cancelled
4. **Date Range Filtering**: Filter sleep records by date range with efficient date-based queries

### Social Features
1. **User Management**: User accounts with status tracking (active/inactive) and follower counts
2. **Social Following**: Follow and unfollow other users with follower/following statistics
3. **Friends' Sleep Records**: View sleep records of followed users from the past week, sorted by duration
4. **User Search**: Search users by name or username with case-insensitive matching

### Performance & Scalability
1. **Redis Caching**: 15-minute TTL for following relationships, 5-minute TTL for leaderboards
2. **Pagination Support**: Efficient pagination for all list endpoints (users, followers, sleep records)
3. **Database Optimization**: Smart indexing strategy with composite indexes for common query patterns
4. **Cache Invalidation**: Automatic cache clearing on follow/unfollow and sleep record updates

### Technical Features
1. **Username System**: Unique usernames alongside display names for better identification
2. **TimeHelper Integration**: Consistent timezone handling across the application
3. **Transaction Safety**: Database transactions for atomic operations (clock-in, follow/unfollow)
4. **Input Validation**: Comprehensive validation with contracts for filtering and search parameters

## Setup

### Prerequisites
- Ruby 3.3.0
- PostgreSQL
- Redis
- Docker & Docker Compose (optional)

### Local Development

```bash
# Install dependencies
bundle install

# Setup environment variables
cp .env.example .env
# Edit .env with your Redis and PostgreSQL settings

# Setup database
rails db:create
rails db:migrate

# Enable caching in development (optional)
rails dev:cache

# Create sample data (optional)
rails db:seed

# Start Redis (required for caching)
redis-server

# Start the server
rails server

# Health check (verify Redis connection)
curl http://localhost:3000/api/v1/health
```

### Docker Development (Not Ready)

## API Documentation

### Authentication
All API endpoints (except user creation) require a `X-User-ID` header with the user's ID.

```
X-User-ID: 1
```

### Endpoints

#### Users

**Create User**
```
POST /api/v1/users
Content-Type: application/json

{
  "user": {
    "name": "John Doe",
    "username": "johndoe"
  }
}
```

**Get Current User Details**
```
GET /api/v1/users/:id
X-User-ID: 1

Response includes follower/following counts:
{
  "message": "Successfully retrieved user details",
  "user": {
    "id": 1,
    "name": "John Doe",
    "username": "johndoe",
    "user_status": "active",
    "created_at": "8 Aug 2023, 10:00:00",
    "total_follower": 3,
    "total_following": 5
  }
}
```

**List All Users (with search and pagination)**
```
GET /api/v1/users?search=john&page=1&per_page=20

Query Parameters:
- search: Search by name or username (optional)
- page: Page number (default: 1)
- per_page: Items per page (default: 20, max: 100)

Response:
{
  "message": "Successfully retrieve list of users",
  "users": [
    {
      "id": 1,
      "name": "John Doe",
      "username": "johndoe",
      "user_status": "active",
      "created_at": "8 Aug 2023, 10:00:00",
      "total_follower": 3,
      "total_following": 5
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_count": 150,
    "total_pages": 8
  },
  "search": "john"
}
```

#### Sleep Records

**Clock In (Go to bed)**
```
POST /api/v1/sleep_records
X-User-ID: 1
Content-Type: application/json

{
  "bedtime": "2023-08-08T22:00:00+07:00" // Optional, defaults to current Asia/Jakarta time
}

Note: All timestamps use Asia/Jakarta timezone by default
```

**Get All Sleep Records (with filtering and pagination)**
```
GET /api/v1/sleep_records?filter[date_from]=2024-01-01&filter[date_to]=2024-01-31&filter[status]=completed&page=1&per_page=20
X-User-ID: 1

Query Parameters:
- filter[date_from]: Start date (YYYY-MM-DD format, optional)
- filter[date_to]: End date (YYYY-MM-DD format, optional)  
- filter[status]: Filter by status (incomplete/completed/cancelled, optional)
- page: Page number (default: 1)
- per_page: Items per page (default: 20, max: 100)

Response:
{
  "sleep_records": [...],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_count": 45,
    "total_pages": 3
  },
  "filters": {
    "date_from": "2024-01-01",
    "date_to": "2024-01-31", 
    "status": "completed"
  }
}
```

**Update Sleep Record (Rate quality, add notes, change status)**
```
PATCH /api/v1/sleep_records/:id
X-User-ID: 1
Content-Type: application/json

{
  "score": 4,
  "notes": "Great sleep last night!",
  "status": "completed",
  "wake_time": "2023-08-09T06:00:00+07:00"
}
```

**Get Following Users' Sleep Records (Last Week, with pagination)**
```
GET /api/v1/sleep_records/following_records?page=1&per_page=20
X-User-ID: 1

Query Parameters:
- page: Page number (default: 1)
- per_page: Items per page (default: 20, max: 100)

Response:
{
  "sleep_records": [...],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_count": 35,
    "total_pages": 2
  }
}

Note: Results are cached for 5 minutes for optimal performance
```

#### Following/Followers

**Follow a User**
```
POST /api/v1/follows
X-User-ID: 1
Content-Type: application/json

{
  "followed_id": 2
}
```

**Unfollow a User**
```
DELETE /api/v1/follows/2
X-User-ID: 1
```

**Get Following List (with pagination)**
```
GET /api/v1/follows?page=1&per_page=20
X-User-ID: 1

Response:
{
  "following": [...],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_count": 25,
    "total_pages": 2
  }
}
```

**Get Followers List (with pagination)**
```
GET /api/v1/users/:id/followers?page=1&per_page=20
X-User-ID: 1

Response:
{
  "message": "Successfully retrieved followers",
  "followers": [
    {
      "id": 2,
      "name": "Alice Johnson",
      "username": "alice_j",
      "user_status": "active",
      "created_at": "8 Aug 2023, 09:30:00",
      "total_follower": 1,
      "total_following": 3
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_count": 15,
    "total_pages": 1
  }
}
```

### Response Examples

**Sleep Record Response**
```json
{
  "id": 1,
  "user_id": 1,
  "user_name": "John Doe",
  "user_username": "johndoe",
  "bedtime": "8 Aug 2023, 22:00:00",
  "wake_time": "9 Aug 2023, 06:00:00",
  "duration_minutes": 480,
  "duration_hours": 8.0,
  "score": 4,
  "notes": "Great sleep last night!",
  "status": "completed",
  "quality_text": "Good",
  "created_at": "8 Aug 2023, 22:00:00"
}
```

**Following Users' Sleep Records Response**
```json
[
  {
    "id": 5,
    "user_id": 2,
    "user_name": "Alice",
    "user_username": "alice_s",
    "bedtime": "7 Aug 2023, 23:00:00",
    "wake_time": "8 Aug 2023, 08:00:00",
    "duration_minutes": 540,
    "duration_hours": 9.0,
    "score": 5,
    "notes": "Perfect night!",
    "status": "completed",
    "quality_text": "Excellent",
    "created_at": "7 Aug 2023, 23:00:00"
  },
  {
    "id": 6,
    "user_id": 3,
    "user_name": "Bob",
    "user_username": "bob_wilson",
    "bedtime": "7 Aug 2023, 22:30:00",
    "wake_time": "8 Aug 2023, 07:00:00",
    "duration_minutes": 510,
    "duration_hours": 8.5,
    "score": 3,
    "notes": "Woke up a few times",
    "status": "completed",
    "quality_text": "Fair",
    "created_at": "7 Aug 2023, 22:30:00"
  }
]
```

## Sleep Tracking Behavior

### Clock In/Out System

The clock-in operation works as follows:

1. **First clock-in**: Creates a new sleep record with `status: "incomplete"`
2. **Subsequent clock-ins**: 
   - Completes the previous incomplete record (sets wake_time, duration, and `status: "completed"`)
   - Creates a new sleep record with the new bedtime

### Sleep Record Status

- **incomplete**: User has gone to bed but hasn't woken up yet (wake_time is null)
- **completed**: Full sleep cycle recorded with both bedtime and wake_time
- **cancelled**: Sleep session was cancelled (e.g., user got up shortly after going to bed)

### Sleep Quality Tracking

- **Score**: 1-5 rating (1=Terrible, 2=Poor, 3=Fair, 4=Good, 5=Excellent)
- **Notes**: Personal reflections and sleep journal entries (private to user)
- **Quality Text**: Human-readable version of the score for display purposes

### User Status

- **active**: Normal user account, can create sleep records and follow others
- **inactive**: Disabled account, cannot perform actions

## Testing

### (Pure Mocks, No Database)
```bash
# Run pure mock unit tests only
rspec
```

## Architecture

### Models & Business Logic
- **User**: User account with name, username, status fields, and follower/following relationships
- **SleepRecord**: Tracks bedtime, wake_time, duration, quality score, notes, and status with Asia/Jakarta timezone
- **Follow**: Join table for user following relationships with proper validation

### Performance & Caching Layer
- **Redis Cache Store**: Rails cache backend with environment-specific namespacing
- **Cache Strategy**: 15-minute TTL for following relationships, 5-minute TTL for leaderboards
- **Automatic Invalidation**: Cache clearing on follow/unfollow and sleep record updates
- **Connection Pooling**: Optimized Redis connections for concurrent requests

### Database Optimization
- **Smart Indexing**: Composite indexes for common query patterns (`user_id + sleep_date`, `user_id + status`)
- **Date-Based Queries**: Dedicated `sleep_date` column for efficient date filtering
- **Foreign Key Constraints**: Data integrity with proper referential constraints
- **Unique Constraints**: Prevention of duplicate follows and usernames

### API Design & Pagination
- **RESTful API**: Consistent resource-based endpoints
- **Kaminari Pagination**: Efficient pagination across all list endpoints
- **Query Parameter Validation**: Contract-based validation for search and filtering
- **Consistent Response Format**: Standardized JSON with pagination metadata

### Service Objects (Clean separation of business logic)
- **SleepRecords::ClockInService**: Atomic sleep tracking with database transactions
- **SleepRecords::UpdateService**: Sleep record updates with cache invalidation
- **Follows::CreateService**: Follow relationships with transaction safety
- **Follows::DestroyService**: Unfollow operations with cache cleanup

### Input Validation & Contracts
- **dry-validation**: Robust input validation framework
- **Available Contracts**: 
  - `Users::IndexContract`: Search and pagination validation
  - `SleepRecords::IndexContract`: Date filtering and pagination validation
  - `SleepRecords::CreateContract` & `UpdateContract`: Sleep record validation
  - `Follows::CreateContract` & `DestroyContract`: Follow operations validation

### Utilities & Helpers
- **TimeHelper**: Centralized timezone utilities (Asia/Jakarta)
- **Pagination Helper**: Standardized pagination metadata generation
- **Health Check**: Redis and database connection monitoring

## Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Key variables:
- `DATABASE_*`: PostgreSQL connection settings
- `REDIS_URL`: Redis connection for caching
- `IS_MAINTENANCE`: Set to "1" to enable maintenance mode
- `SECRET_KEY_BASE`: Application secret (generate with `rails secret`)

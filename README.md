# Manhua Java

A comprehensive Java-based comic management system built with Spring Boot, providing a complete solution for organizing, reading, and managing comic collections.

## Features

### Core Features
- **Comic Library Management**: Organize comics in multiple libraries with metadata support
- **Reading Progress Tracking**: Track reading history, bookmarks, and progress across devices
- **Advanced Tag System**: Categorize comics with hierarchical tags and smart filtering
- **Intelligent Cache Management**: Optimize performance with configurable caching strategies
- **User Settings**: Customizable reading preferences and system configurations
- **RESTful API**: Complete REST API for all functionality

### Additional Features
- **File Format Support**: Support for various comic formats (ZIP, RAR, CBZ, CBR)
- **Image Processing**: Automatic thumbnail generation and image optimization
- **Search & Filter**: Advanced search capabilities with multiple criteria
- **Statistics & Analytics**: Reading statistics and library insights
- **Cross-Platform**: Web-based interface accessible from any device

## Tech Stack

- **Backend**: Java 11+, Spring Boot 2.7.x
- **Database**: H2 Database (embedded)
- **ORM**: Spring Data JPA with Hibernate
- **Security**: Spring Security with JWT authentication
- **Build Tool**: Maven 3.6+
- **API Documentation**: SpringDoc OpenAPI 3
- **Image Processing**: Thumbnailator
- **File Handling**: Apache Commons IO & Compress

## Project Structure

```
manhua-java/
├── backend/
│   └── src/
│       ├── main/
│       │   ├── java/com/manhua/
│       │   │   ├── controller/     # REST Controllers
│       │   │   ├── service/        # Business Logic
│       │   │   ├── repository/     # Data Access Layer
│       │   │   ├── entity/         # JPA Entities
│       │   │   ├── dto/           # Data Transfer Objects
│       │   │   ├── config/        # Configuration Classes
│       │   │   ├── common/        # Common Utilities
│       │   │   └── ManhuaApplication.java
│       │   └── resources/
│       │       └── application.yml
│       └── test/
├── pom.xml
└── README.md
```

## Getting Started

### Prerequisites

- **Java 11** or higher
- **Maven 3.6+**
- **Git** (for cloning the repository)

### Installation

1. **Clone the repository**:
```bash
git clone <repository-url>
cd manhua-java
```

2. **Build the project**:
```bash
mvn clean install
```

3. **Run the application**:
```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`.

### First Run Setup

On first startup, the application will:
- Create the necessary data directories
- Initialize the H2 database with required tables
- Set up default configuration

## API Documentation

Once the application is running, you can access the comprehensive API documentation:

- **Swagger UI**: `http://localhost:8080/swagger-ui.html`
- **OpenAPI JSON**: `http://localhost:8080/v3/api-docs`
- **H2 Console**: `http://localhost:8080/h2-console` (dev mode only)

### API Endpoints Overview

- `/api/libraries` - Comic library management
- `/api/comics` - Comic operations and metadata
- `/api/tags` - Tag system management
- `/api/reading-history` - Reading progress tracking
- `/api/user-settings` - User preferences
- `/api/cache-entries` - Cache management

## Configuration

The application is configured through `application.yml`. Key configuration sections:

### Database Configuration
```yaml
spring:
  datasource:
    url: jdbc:h2:file:${app.data-path}/database/manhua
    driver-class-name: org.h2.Driver
```

### Application Settings
```yaml
app:
  data-path: ./data              # Base data directory
  cache:
    max-size: 1GB               # Maximum cache size
    expire-after-access: 7d     # Cache expiration
  comic:
    supported-formats: [zip, rar, cbz, cbr, 7z]
    supported-images: [jpg, jpeg, png, gif, bmp, webp]
```

### Security Configuration
```yaml
app:
  security:
    cors:
      allowed-origins: ["http://localhost:3000"]
    jwt:
      secret: your-secret-key
      expiration: 24h
```

## Development

### Running in Development Mode

```bash
# Run with dev profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Or set environment variable
export SPRING_PROFILES_ACTIVE=dev
mvn spring-boot:run
```

### Building for Production

```bash
# Build with production profile
mvn clean package -Pprod

# Run the JAR
java -jar target/manhua-java-1.0.0.jar --spring.profiles.active=prod
```

### Testing

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=ComicServiceTest
```

## Usage Examples

### Creating a Comic Library

```bash
curl -X POST http://localhost:8080/api/libraries \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Comics",
    "path": "/path/to/comics",
    "description": "Personal comic collection"
  }'
```

### Adding a Comic

```bash
curl -X POST http://localhost:8080/api/comics \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Example Comic",
    "libraryId": 1,
    "filePath": "/path/to/comic.cbz"
  }'
```

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the port in `application.yml`:
   ```yaml
   server:
     port: 8081
   ```

2. **Database connection issues**: Check the data directory permissions and path configuration.

3. **File access errors**: Ensure the application has read/write permissions to the configured data directories.

### Logging

Logs are written to both console and file (`./data/logs/manhua.log`). Adjust log levels in `application.yml`:

```yaml
logging:
  level:
    com.manhua: DEBUG
    org.springframework: INFO
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Spring Boot team for the excellent framework
- H2 Database for the embedded database solution
- All contributors and users of this project
# Stage 1: Build using minimal, secure JDK base image
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Copy Maven wrapper & project
COPY .mvn .mvn
COPY mvnw pom.xml ./
COPY app ./app

# Build application JAR
RUN ./mvnw -B clean package -DskipTests --file app/pom.xml

# Stage 2: Run with a minimal JRE base image
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy built JAR from previous stage
COPY --from=build /app/app/target/*.jar app.jar

# Add non-root user
RUN adduser -D appuser && chown -R appuser:appuser /app
USER appuser

# Expose app port
EXPOSE 8080

# Health check (Spring Boot actuator endpoint)
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O /dev/null http://localhost:8080/actuator/health || exit 1

# Metadata labels (optional but recommended)
LABEL maintainer="dev-team@example.com" \
      org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.description="Spring Boot application"

# Start the application
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-XX:InitialRAMPercentage=50.0", "-jar", "app.jar"]


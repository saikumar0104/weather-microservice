# Use official OpenJDK 17 image
FROM eclipse-temurin:17-jdk-alpine

# Set working directory inside container
WORKDIR /app

# Copy Maven-built jar into container
COPY target/weather-microservice-1.0.0.jar weather-microservice.jar

# Expose port 8080
EXPOSE 8080

# Run the jar
ENTRYPOINT ["java", "-jar", "weather-microservice.jar"]

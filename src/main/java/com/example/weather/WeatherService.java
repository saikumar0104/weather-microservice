package com.example.weather;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Map;

@Service
public class WeatherService {

    @Autowired
    private WeatherRepository weatherRepository;

    // Map of cities with their latitude and longitude
    private static final Map<String, String> CITY_COORDS = Map.of(
            "Mumbai", "19.07,72.87",
            "Delhi", "28.61,77.23",
            "Chennai", "13.08,80.27",
            "Hyderabad", "17.38,78.48",
            "Bengaluru", "12.97,77.59"
    );

    // Scheduled to run every 5 minutes
    @Scheduled(fixedRate = 300000)
    public void fetchWeatherData() {
        RestTemplate restTemplate = new RestTemplate();

        CITY_COORDS.forEach((city, coords) -> {
            try {
                String[] latlon = coords.split(",");
                String url = String.format(
                        "https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&current_weather=true",
                        latlon[0], latlon[1]
                );

                String response = restTemplate.getForObject(url, String.class);
                JSONObject json = new JSONObject(response);
                JSONObject current = json.getJSONObject("current_weather");

                Weather weather = new Weather();
                weather.setTemperature(current.getDouble("temperature"));
                weather.setWindSpeed(current.getDouble("windspeed"));
                weather.setWindDirection(current.getInt("winddirection"));
                weather.setTimestamp(LocalDateTime.now(ZoneId.of("Asia/Kolkata")));
                weather.setCityName(city);

                weatherRepository.save(weather);
                System.out.println("✅ Saved " + city + ": " + current.getDouble("temperature") + "°C");

            } catch (Exception e) {
                System.err.println("❌ Error fetching data for " + city + ": " + e.getMessage());
            }
        });
    }
}

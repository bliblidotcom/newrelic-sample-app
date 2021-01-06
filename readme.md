This is a sample app that demonstrate problem in New Relic instrumentation when used with blibli
spring boot based app.

## How to run

- `mvn clean package -DskipTests`
- `docker build -t newrelic-sample-app:latest --build-arg JARFILE=./example-app/target/example-app-0.0.1-SNAPSHOT.jar .`
- `docker-compose up -d`
- `docker run -p 8080:8080 -e NEW_RELIC_LICENSE_KEY=my-key -e NEW_RELIC_APP_NAME=dev_newrelic-sample-app -e SPRING_PROFILES_ACTIVE=dev --name newrelic-sample-app --network development newrelic-sample-app:latest`

## Quick code walkthrough

The web controller can be found in ...

The repository is found in ...

All else is just boilerplate maven submodule that should not be too important in newrelic case.

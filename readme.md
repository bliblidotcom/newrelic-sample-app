This is a sample app that demonstrate problem in New Relic instrumentation when used with blibli
spring boot based app.

## How to run

1. `mvn clean package -DskipTests`
2. `docker build -t newrelic-sample-app:latest --build-arg JARFILE=./example-app/target/example-app-0.0.1-SNAPSHOT.jar .`
3. `docker-compose up -d`
4. `docker run -p 8080:8080 -e NEW_RELIC_LICENSE_KEY=my-key -e NEW_RELIC_APP_NAME=dev_newrelic-sample-app -e SPRING_PROFILES_ACTIVE=dev --name newrelic-sample-app --network development newrelic-sample-app:latest`

## Quick code walkthrough

The web controller can be found in [controller package](https://github.com/bliblidotcom/newrelic-sample-app/tree/newrelic-sample/example-web/src/main/java/com/blibli/oss/backend/example/web)

The repository is found in [repository package](https://github.com/bliblidotcom/newrelic-sample-app/blob/newrelic-sample/example-repository/src/main/java/com/blibli/oss/backend/example/repository/CustomerRepository.java)

The service layer can be found in [command package](https://github.com/bliblidotcom/newrelic-sample-app/tree/newrelic-sample/example-command-impl/src/main/java/com/blibli/oss/backend/example/command/impl)

All else is just boilerplate maven submodule that should not be too important in newrelic case.

## Command to reproduce tracing problem /NettyDispatcher

- `ab -c 10 -n 3000 http://newrelic-sample-app.qa1-sg.cld/binlist/200 `
- `curl --location --request POST 'http://newrelic-sample-app.qa1-sg.cld/api/customers/' --header 'Content-Type: application/json' --data-raw '{firstName": "John", "lastName": "Doe", "email": "john.doe@blibli.com", "gender": "MALE"}'`
- `ab -c 10 -n 3000 http://newrelic-sample-app.qa1-sg.cld/api/customers/0b130c67-74c2-45e9-a60b-7193cac26ba6`

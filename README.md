# eprints-docker
Quick way to get an instance of EPrints up &amp; running

1. add "dev-eprints" as an alias for 127.0.0.1 in your /etc/hosts
2. docker-compose build
3. docker-compose run
4. firefox http://dev-eprints (admin password is "admin")

### Things to know (and not complain about)

- the Dockerfile is hardcoded with EPrints version 3.3.15
- the setup scripts (scripts/epadmin*) have only been tested with 3.3.15
- it is not a development environment where you can edit source files live,
  but it could be adapted for this purpose

### Ideas / things to improve

- The first time that you `docker-compose run`, MySQL will take longer than
  usual to initialize, and the web container will most likely fail to complete
  the setup. One solution is to Ctrl-C and restart, or use a `wait-for-it`
  script in the docker-compose command.
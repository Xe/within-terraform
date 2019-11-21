FROM xena/nim:0.20.2 AS build
WORKDIR /dyson
COPY . .
RUN nimble update && nimble build

FROM xena/alpine
COPY --from=build /dyson/bin/dyson /usr/local/bin/dyson
COPY gh_actions.sh /entrypoint.sh

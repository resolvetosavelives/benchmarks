FROM benchmarksbase:latest as base
FROM ruby:alpine
COPY --from=base /app /app

CMD ["bin/puma", "-p" "$PORT"]

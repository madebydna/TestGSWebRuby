web: bundle exec rails s -p 3000 -b 0.0.0.0
sidekiq: bundle exec sidekiq
client: sh -c 'rm app/assets/webpack/* || true && cd client && npm run build:development'

FROM ruby:3.2.2

# 開発に必要なパッケージのインストール
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    git

WORKDIR /app

# GemfileとGemfile.lockをコピーしてbundle install
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
# Precompiling assets for production without requiring secret_key_base
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
RUN bundle install

# アプリケーションコード全体をコピー
COPY . /app

# エントリーポイントの設定
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
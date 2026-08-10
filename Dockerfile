FROM ruby:3.3.12

# 開発・アセットビルドに必要なパッケージのインストール（npm, yarnを追加）
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    git && \
    npm install -g yarn

WORKDIR /app

# 1. まず Gemfile をコピーして Gem をインストール
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# 2. アプリケーションコード全体をコピー
COPY . /app

# 3. コードがコピーされた後にアセットをプリコンパイル
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# エントリーポイントの設定
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
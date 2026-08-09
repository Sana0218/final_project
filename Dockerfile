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
RUN bundle install

# アプリケーションコード全体をコピー
COPY . /app

# エントリーポイントの設定
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
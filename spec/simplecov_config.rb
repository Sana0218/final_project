# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails' do
  enable_coverage :branch

  skip '/spec/'
  skip 'app/channels/'
  skip 'app/jobs/'
  skip 'app/mailers/'

  group 'Models', 'app/models'
  group 'Controllers', 'app/controllers'
  group 'Services', 'app/services'

  coverage(:line) { minimum 95 }
  coverage(:line) { minimum_per_file 80 }
end

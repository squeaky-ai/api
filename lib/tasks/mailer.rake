# typed: false
# frozen_string_literal: true

task :mailer, [:action] => :environment do |_task, args|
  raise ArgumentError, "Missing action, usage: bundle exec rake mailer'[ProductUpdatesMailer#january_2023]'" unless args[:action]

  class_name, method_name = args[:action].split('#')
  klass = Object.const_get(class_name)

  raise ArgumentError "#{args[action]} does not map to a mailer" unless klass.respond_to?(method_name)

  User.find_each do |user|
    klass.send(method_name, user).deliver_later
  end
end

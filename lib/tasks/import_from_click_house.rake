# frozen_string_literal: true

task :import_from_click_house, [:model] => :environment do |_task, args|
  raise ArgumentError, "Missing model, usage: bundle exec rake import_from_click_house'[ClickEvent]'" unless args[:model]

  click_house_class = Object.const_get("ClickHouse::#{args[:model]}")
  pg_class = Object.const_get(args[:model])

  page = 0
  batch_size = 10_000

  loop do
    puts "Backfilling page #{page}"

    records = Sql::ClickHouse.select_all(
      "SELECT * FROM #{click_house_class.table_name} LIMIT #{batch_size} OFFSET #{page * batch_size}"
    )

    records = records.map { |x| x.except('uuid') }

    if records.zero?
      puts "Completed after #{page} pages"
      break
      
    end

    pg_class.insert_all(records) # rubocop:disable Rails/SkipsModelValidations
  end

  puts 'Done!'
end

# frozen_string_literal: true

class AddUniqueArrayFunction < ActiveRecord::Migration[6.1]
  def up
    connection.execute(%q(
      create or replace function public.array_unique(arr anyarray)
      returns anyarray as $body$
        select array( select distinct unnest($1) )
      $body$ language 'sql';
    ))
  end
  
  def down
    connection.execute(%q(
      drop function public.array_unique;
    ))
  end
end

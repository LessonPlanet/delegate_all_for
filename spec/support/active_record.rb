ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Migration.create_table :parents do |t|
  t.string :one
  t.string :two
end
ActiveRecord::Migration.create_table :children do |t|
  t.string :two
  t.string :three
  t.string :four
  t.integer :parent_id
  t.timestamps
end

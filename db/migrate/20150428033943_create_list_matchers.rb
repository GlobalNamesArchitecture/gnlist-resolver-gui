# frozen_string_literal: true

# Migration to create list_matchers table
class CreateListMatchers < ActiveRecord::Migration[4.2]
  def change
    create_table :list_matchers do |t|
      t.string :filename
      t.string :input
      t.string :output
      t.string :token
      t.string :col_sep
      t.string :status, default: :init
      t.integer :data_source_id
      t.boolean :skip_original, default: false
      t.boolean :stop_trigger, default: false
      t.jsonb :alt_headers
      t.jsonb :params
      t.jsonb :input_sample
      t.jsonb :stats

      t.timestamps null: false
    end
  end
end

class CreateCASinoSessionLogs < ActiveRecord::Migration
  def change
    create_table :casino_session_logs do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :ticket_granting_ticket, index: true
      t.text :user_agent
      t.text :service

      t.timestamps null: false
    end
  end
end

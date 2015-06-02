class CASino::SessionLog < ActiveRecord::Base
  belongs_to :ticket_granting_ticket
  belongs_to :user
end


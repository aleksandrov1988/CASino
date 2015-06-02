class AddIpToCASinoTicketGrantingTickets < ActiveRecord::Migration
  def change
    add_column :casino_ticket_granting_tickets, :remote_ip, :inet
  end
end

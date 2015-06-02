
class CASino::User < ActiveRecord::Base
  serialize :extra_attributes, Hash

  has_many :ticket_granting_tickets
  has_many :two_factor_authenticators
  has_many :logs,->{order(created_at: :desc)}, class_name: 'CASino::SessionLog', dependent: :destroy

  def active_two_factor_authenticator
    self.two_factor_authenticators.where(active: true).first
  end
end

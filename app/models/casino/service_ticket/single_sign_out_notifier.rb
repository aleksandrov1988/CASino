require 'builder'
require 'faraday'

class CASino::ServiceTicket::SingleSignOutNotifier
  def initialize(service_ticket)
    @service_ticket = service_ticket
  end

  def notify
    send_notification @service_ticket.service, build_xml
  end

  private
  def build_xml
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.samlp :LogoutRequest,
              'xmlns:samlp' => 'urn:oasis:names:tc:SAML:2.0:protocol',
              'xmlns:saml' => 'urn:oasis:names:tc:SAML:2.0:assertion',
              ID: SecureRandom.uuid,
              Version: '2.0',
              IssueInstant: Time.now do |logout_request|
      logout_request.saml :NameID, '@NOT_USED@'
      logout_request.samlp :SessionIndex, @service_ticket.ticket
    end
    xml.target!
  end

  def send_notification(url, xml)
    uri=URI.parse(url)
    host=uri.host
    if host
      begin
        Resolv.getaddress(host)
      rescue Exception => e
        Rails.logger.info "Error resolving URL '#{url}' '#{e.message}' for '#{@service_ticket.ticket}'"
        return false
      end

      begin
        Rails.logger.info "Sending Single Sign Out notification for ticket '#{@service_ticket.ticket}'"
        result = Faraday.post(url, logoutRequest: xml) do |request|
          request.options[:timeout] = CASino.config.service_ticket[:single_sign_out_notification][:timeout]
        end
        if result.success?
          Rails.logger.info "Logout notification successfully posted to #{url}."
          return true
        else
          Rails.logger.warn "Service #{url} responded to logout notification with code '#{result.status}'!"
          return false
        end
      rescue Faraday::Error::ClientError => error
        Rails.logger.warn "Failed to send logout notification to service #{url} due to #{error}"
        return false
      end
    end
  end
end

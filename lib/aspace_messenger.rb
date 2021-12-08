# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

class ASpaceMessenger
  attr_reader :app, :context, :enabled, :payload, :uri, :url
  def initialize(config = {})
    @app     = config.fetch(:app, nil)
    @context = config.fetch(:context, {})
    @enabled = config.fetch(:enabled, false)
    @payload = config.fetch(:payload, nil)
    @url     = config.fetch(:url, nil)
    @uri     = URI.parse(url)
  end

  def deliver
    http = prepare_http
    request = prepare_request
    http.request(request)
  end

  def ready?
    return false unless enabled && payload && url

    true
  end

  def self.startup(server)
    messenger = new(AppConfig[:aspace_messenger][:on_startup])
    return unless messenger.app == server && messenger.ready?

    begin
      messenger.deliver
    rescue StandardError => e
      warn "There was an error sending the #{server} startup message request:\n#{e.message}\n#{e.backtrace}"
    end
  end

  private

  def prepare_http
    http = Net::HTTP.new(uri.host, uri.port)
    http.max_retries = 0
    http.read_timeout = 60
    http.use_ssl = uri.scheme == 'https'
    http
  end

  def prepare_request
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    request.body = payload.call(resolve_context)
    request
  end

  def resolve_context
    context.respond_to?(:call) ? context.call : context
  end
end

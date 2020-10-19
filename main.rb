require 'aws-sdk'
require 'base64'
require 'json'
require 'logger'
require 'net/http'

# kms = Aws::KMS::Client.new
# HOOK_URL = kms.decrypt(ciphertext_blob: Base64.decode64(ENV['ENCRYPTED_HOOK_URL']))[:plaintext]
HOOK_URL = ENV['HOOK_URL']

def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  logger.debug event.to_json

  message = JSON.parse(event['Records'][0]['Sns']['Message'])
  raw = message['content']

  encoding = raw.match(/(?<=Content-Transfer-Encoding: )(.*)/)[0]
  logger.debug "encoding : #{encoding}"

  boundary = raw.match(/(?<=boundary=")(.*)(?=")/)[0]
  logger.debug "boundary : #{boundary}"
  body = raw.split(boundary)[2].split(/\r\n\r\n/)[1].gsub(/\r\n--/, '')

  if encoding.start_with?('base64') then
    body = Base64.decode64(body).force_encoding(Encoding::UTF_8)
  end

  from = message['mail']['commonHeaders']['from'][0]
  subject = message['mail']['commonHeaders']['subject']
  text = "From : #{from}\nSubject : #{subject}\n----------\n#{body}"
  logger.debug "\n#{text}"

  uri = URI.parse(HOOK_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.post(uri.path, { text: text }.to_json)
end

# require 'active_support'
# require 'active_support/core_ext'
# event = {}
# lambda_handler(event: event.with_indifferent_access, context: nil)

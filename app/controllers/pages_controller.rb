require 'rest-client'

class PagesController < ApplicationController
  def index
    receipient = create_receipient(params[:receipient_name])
    render json: {receipient: receipient}
  end

  private
  def authenticate_to_coolpay_api
    resp = {}
    values = {username: 'EmbaM',apikey: '778C007BD92DDEC3'}
    headers = {content_type: 'application/json'}

    begin
      response = RestClient.post 'https://coolpay.herokuapp.com/api/login', values, headers
      resp = JSON.parse(response)
    rescue => e
      Rails.logger.error "Error in authenticate_to_coolpay_api: #{e}"
    end

    resp["token"] unless resp.empty?
  end

  def api_token
    @token ||= authenticate_to_coolpay_api
  end

  def create_receipient(name)
    values = {recipient: {name: name}}
    headers = { content_type: 'application/json', authorization: "Bearer 12345.#{api_token}.67890"}
    receipient = {}

    begin
      response = RestClient.post 'https://coolpay.herokuapp.com/api/recipients', values, headers
      receipient = JSON.parse(response)
    rescue => e
      Rails.logger.error "Error in create_receipient: #{e}"
    end

    receipient
  end

  def create_payment(fields)
    values = {
      payment: {
        amount: fields[:amount],
        currency: fields[:currency],
        recipient_id: fields[:recipient_id]
      }
    }

    headers = {
      content_type: 'application/json',
      authorization: "Bearer 12345.#{api_token}.67890"
    }

    payment = {}

    begin
      response = RestClient.post 'https://coolpay.herokuapp.com/api/payments', values, headers
      payment = JSON.parse(response)
    rescue => e
      Rails.logger.error "Error in create_payment: #{e}"
    end

    payment
  end
end


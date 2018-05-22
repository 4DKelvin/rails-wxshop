class VueController < ApplicationController
  wechat_responder
  wechat_api

  before_action :check_format, :check_authentication, only: [:viewer]

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def check_format
    unless params[:format].to_s.upcase == 'HTML'
      not_found
    end
  end

  def localhost?
    request.url.upcase.include?('192.168') or request.url.upcase.include?('localhost')
  end


  def check_authentication
    unless spree_current_user
      host = ENV["trusted_domain_fullname"] || "#{request.protocol}#{request.host_with_port}"

      sign_in(Spree::User.generate_from_openid('oOHPVw8w8d0Zy1jaPhrRRTC8BbmI')) if localhost?

      wechat_oauth2('snsapi_userinfo', "#{host}#{request.fullpath}") do |openid, access_info|
        sign_in(Spree::User.generate_from_openid(openid, access_info['access_token']), scope: :spree_user)
      end unless localhost?
    end
  end


  def notify
    result = Hash.from_xml(request.body.read)['xml']
    if WxPay::Sign.verify?(result)
      begin
        if result["out_trade_no"].present?
          pay = Spree::Payment.find_by(number: result["out_trade_no"])
          pay.capture! if pay.payment_source
        end
      rescue => e
        logger.error e
        logger.error e.backtrace.first(5).join("\n")
      end
      render xml: {return_code: 'SUCCESS', return_msg: 'OK'}.to_xml(root: 'xml', dasherize: false)
    else
      render xml: {return_code: 'FAIL', return_msg: 'Signature Error'}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def viewer
    @name ||= params[:name] || 'index'
    render template: "vue" rescue not_found
  end
end
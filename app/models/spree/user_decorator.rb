Spree::User.class_eval do

  def self.ransackable_attributes(auth_object = nil)
    %w[id nickname]
  end

  def self.generate_from_openid(openid, access_token = '')
    require 'ffaker'
    user = self.find_by(openid: openid)
    user = self.create({
                           email: FFaker::Internet.unique.email,
                           password: FFaker::Name.unique.name,
                           openid: openid,
                           access_token: access_token
                       }) if user.nil?
    user.refresh_wx_user!
    user
  end

  def refresh_wx_user!
    wx = {}
    if openid.present? && access_token.present?
      wx = Wechat.api.web_userinfo(access_token, openid).as_json
      user.update(:avatar => wx["headimgurl"], :nickname => wx["nickname"])
    end
    wx
  end

  # 是否关注公众号
  def subscribe
    refresh_wx_user!["subscribe"] == 1
  end

end
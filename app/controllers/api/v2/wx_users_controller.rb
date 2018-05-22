module Spree
  module Api
    module V2
      class WxUsersController < Spree::Api::BaseController
        rescue_from Spree::Core::DestroyWithOrdersError, with: :error_during_processing

        def show
          render_ok(@current_api_user)
        end

        def up_token
          render_ok({
                        domain: Qiniu::DOMAIN,
                        uptoken: Qiniu::Auth.generate_uptoken(Qiniu::Auth::PutPolicy.new(
                            Qiniu::BUCKET, # 存储空间
                            nil, # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
                            3600 # token 过期时间，默认为 3600 秒，即 1 小时
                        ))
                    })
        end
      end
    end
  end
end

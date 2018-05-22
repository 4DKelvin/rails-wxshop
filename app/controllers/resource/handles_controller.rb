module Resource
  class HandlesController < ApplicationController

    skip_before_action :verify_authenticity_token, only: [:create]


    def show
      handle_file
    end

    def create
      handle_file
    end

    private
    #ueditor的配置
    def handle_file
      uditor_action = request.fullpath.to_s.split('action=').last.split('&').first
      return if uditor_action.blank?
      cur_action = uditor_action

      #刚进入页面时editor会进行config的访问
      if cur_action == "config"
        json = File.read("#{Rails.root.to_s}/public/ueditor/config.json")
        json = json.gsub(/\/\*[\s\S]+?\*\//, "")
        result = JSON.parse(json).to_s
        result = result.gsub(/=>/, ":")
        render :plain => result
      elsif cur_action == "uploadimage"
        upload_image
      elsif cur_action == "uploadvideo"
        respond_result
      elsif cur_action == "catchimage"
        catch_image(params[:source])
      else
        respond_result
      end
    end

    def upload_image
      key = get_random_string.to_s + '.jpg'
      Qiniu::Storage.upload_with_token_2(
          Qiniu::Auth.generate_uptoken(Qiniu::Auth::PutPolicy.new(
              Qiniu::BUCKET, # 存储空间
              key, # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
              3600 # token 过期时间，默认为 3600 秒，即 1 小时
          )),
          params[:upfile].path,
          key,
          nil, # 可以接受一个 Hash 作为自定义变量，请参照 http://developer.qiniu.com/article/kodo/kodo-developer/up/vars.html#xvar
          bucket: Qiniu::BUCKET
      )
      respond_result(key, 'SUCCESS')
    end

    def catch_image(sources)
      callback = params[:callback]
      list = []
      state = 'success'
      sources.each do |source|
        key = get_random_string.to_s + '.jpg'
        Qiniu::Storage.fetch(
            Qiniu::BUCKET,
            source,
            key
        )
        list.push({
                      url: "#{Qiniu::DOMAIN}/#{key}",
                      source: source,
                      state: state
                  })
      end
      response_text = {:state => state, :list => list}.to_json.to_s
      if callback.blank?
        render :plain => response_text
      else
        render :plain => "<script>" + callback + "(" + response_text + ")</script>"
      end
    end


    def respond_result(filename = '', status = '')
      callback = params[:callback]
      response_text = {
          :name => filename.blank? ? '' : filename,
          :originalName => filename.blank? ? '' : filename,
          :size => '',
          :state => status,
          :type => filename.blank? ? '' : File.extname(filename),
          :url => filename.blank? ? '' : "#{Qiniu::DOMAIN}/#{filename}",
      }.to_json.to_s

      if callback.blank?
        render :plain => response_text
      else
        render :plain => "<script>" + callback + "(" + response_text + ")</script>"
      end
    end


    def get_random_string(num = 5)
      #5是指生成字符串的个数，默认为5
      rand(36 ** num).to_s(36)
    end


  end
end
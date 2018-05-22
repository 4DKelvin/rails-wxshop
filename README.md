# 微信商城框架

* 由 `gem spree` 创建
* 整合 `gem qiniu` 七牛云存储
* 整合 `gem wechat` 微信公众号
* 整合 `gem wxpay` 微信支付
* 整合 `gem webpacker` 前端资源管理
* 整合 `ueditor` 富文本编辑器

#### 创建后台管理员
````shell
bundle exec spree_auth:admin:create
````

#### 配置七牛云镜像存储与CDN
修改 `config/application.yml` 文件
````yaml
default: &default
  qiniu_domain: "qiniu_domain"
  qiniu_access_key: "qiniu_access_key"
  qiniu_secret_key: "qiniu_secret_key"
  qiniu_bucket: "qiniu_bucket"

production:
  <<: *default

development:
  <<: *default

test:
  <<: *default
````

#### 配置微信公众号与微信支付
修改 `config/wechat.yml` 文件
````yaml
default: &default
  appid: "appid"
  secret: "secret"
  key:  "key"
  mchid: "mchid"
  token: "token"
  access_token: "/var/tmp/wechat_access_token"
  jsapi_ticket: "/var/tmp/wechat_jsapi_ticket"
  encrypt_mode: false # if true must fill encoding_aes_key
  encoding_aes_key:  ""

production:
  <<: *default

development:
  trusted_domain_fullname: "trusted_domain_fullname"
  <<: *default

test:
  <<: *default
````

#### 微信支付支持
````shell
bundle exec rake payment:wechat:install
````

#### 微信支付（JSAPI Package）
````ruby
order = Spree::Order.first
# `request` 必需在 Controller 
# `notify_wx_url` 是一个路由地址 
# `wx_package` 返回到前端即可调起微信支付 
wx_package = order.generate_pay_params!(request.remote_ip, notify_wx_url)
````

#### 微信菜单配置
修改 `config/wechat_menu.yml` 文件
````yaml
button:
 -
  type: "view"
  name: "商城首页"
  url:  "url"
 -
````
上传到公众号，需要执行 `rake` 任务
````shell
bundle exec rake menu:upload
````

#### 国际化
编辑 `config/initializers/locale.rb` 文件修改默认语言
````ruby
I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
I18n.available_locales = [:en, 'zh-CN']
I18n.default_locale = 'zh-CN' #默认语言
````
编辑 `config/locales/` 目录下文件，修改文本

#### 快速下单（跳过繁琐的步骤直接到支付）
````ruby
order = Spree::Order.first
order.quick_checkout!('contact_name','contact_phone')
````

## 前端部分

#### 开启 `webpack` 调试服务器

````shell
bin/webck-dev-server
````

#### 创建页面
````
app/frontend/views/#{name}.vue => http://localhost:3000/#{name}.html
````
目录 `app/frontend/views` 下创建 `#{name}.vue` 文件

即可访问 `http://localhost:3000/#{name}.html`

#### Webpack与程序入口
入口文件为 `app/frontend/bootstrap/bundle.js`
````javascript
import Vue from 'vue';
import $ from 'jquery';
import axios from 'axios';

const Page = () => import('../views/' + $('body').attr('page') + '.vue');

axios.defaults.headers.common['X-CSRF-Token'] = $('meta[name="csrf-token"]').attr('content');
window.$ = $;
window.Vue = Vue;
window.Axios = axios;
Vue.prototype.$axios = axios;
//初始化Vue
window.vm = new Vue({
    el: document.body.appendChild(document.createElement('el')),
    render: x => x(Page),
});
````
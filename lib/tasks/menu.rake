
namespace :menu do
  desc "TODO"
  task upload: :environment do
    Wechat.api.menu_create YAML.load_file 'config/wechat_menu.yml'
  end
end

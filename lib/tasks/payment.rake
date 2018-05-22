namespace :payment do
  namespace :wechat do
    desc "TODO"
    task install: :environment do
      start = Time.now.to_i
      puts '--------------------------------'
      puts '使系统支持微信支付'
      puts '--------------------------------'
      country = Spree::Country.find_by(:iso_name => 'CHINA') || Spree::Country.create(name: '中国', iso_name: 'CHINA')
      country.update!(name: '中国',
                      states_required: true,
                      zipcode_required: true)
      puts '创建国家...成功'

      country.states.create(:name => '广东',
                            abbr: "gd") unless country.states.any?
      puts '创建省份...成功'
      if Spree::Zone.any?
        zone = Spree::Zone.first
        zone.update!(:name => '亚洲',
                     :description => 'Asia',
                     :default_tax => true,
                     :kind => 'country')
        zone.countries << country
      else
        country.zones.create(:name => '亚洲',
                             :description => 'Asia',
                             :default_tax => true,
                             :kind => 'country') unless country.zones.any?
      end
      puts '创建区域...成功'
      if Spree::StockLocation.any?
        Spree::StockLocation.first.update!(:name => '默认仓库',
                                           :admin_name => 'Default',
                                           :country => country,
                                           :propagate_all_variants => true,
                                           :backorderable_default => true,
                                           :active => true)
      else
        Spree::StockLocation.create(:name => '默认仓库',
                                    :admin_name => 'Default',
                                    :country => country,
                                    :propagate_all_variants => true,
                                    :backorderable_default => true,
                                    :active => true)
      end
      puts '创建仓库...成功'
      if Spree::ShippingCategory.any?
        Spree::ShippingCategory.first.update!(:name => '平邮')
      else
        Spree::ShippingCategory.create(:name => '平邮')
      end
      puts '创建配送类型...成功'
      unless Spree::ShippingMethod.any?
        Spree::ShippingMethod.create(:name => '商家配送',
                                     :admin_name => 'Merchant Shipment',
                                     :display_on => 'both',
                                     :code => '510000')
      end
      method = Spree::ShippingMethod.first
      calculator = Spree::Calculator::Shipping::FlatRate.create(:type => 'Spree::Calculator::Shipping::FlatRate',
                                                                :calculable_type => 'Spree::ShippingMethod',
                                                                :preferences => {:currency => 'CNY', :amount => 0})
      method.update!(:name => '商家配送',
                     :admin_name => 'Merchant Shipment',
                     :display_on => 'both',
                     :code => '510000',
                     :calculator => calculator)

      method.shipping_categories << Spree::ShippingCategory.first unless method.shipping_categories.any?
      method.zones << Spree::Zone.first unless method.zones.any?
      puts '创建配送方式...成功'
      payment = Spree::PaymentMethod.find_by(:type => 'Spree::PaymentMethod::Check',
                                             :display_on => 'both')
      if payment.present?
        payment.update(:type => 'Spree::PaymentMethod::Check',
                       :name => '微信支付',
                       :active => true,
                       :display_on => 'both')
      else
        Spree::PaymentMethod.create(:type => 'Spree::PaymentMethod::Check',
                                    :name => '微信支付',
                                    :active => true,
                                    :display_on => 'both')
      end
      puts '创建微信支付...成功'
      currency = Spree::Preference.find_by(:key => 'spree/app_configuration/currency')
      if currency.present?
        currency.update!(:value => 'CNY')
      else
        Spree::Preference.create(:key => 'spree/app_configuration/currency', :value => 'CNY')
      end
      puts '修改默认货币为人民币'
      puts '--------------------------------'
      puts "所有任务已经完成，耗时：#{Time.now.to_i - start} 毫秒"
      puts '--------------------------------'

    end
  end
end

Spree::Order.class_eval do
  scope :total, -> {
    where(state: 'complete').where.not(payment_state: nil, shipment_state: nil)
  }
  scope :unpaid, -> {
    where(payment_state: 'balance_due')
  }
  scope :unshipped, -> {
    where(payment_state: 'paid').where.not(shipment_state: 'shipped')
  }
  scope :success, -> {
    where(payment_state: 'paid', shipment_state: 'shipped')
  }

  def quick_checkout!(contact_name, contact_phone, address = '...')
    transaction do
      addr = address_params(contact_name, contact_phone, address)
      pay = Spree::PaymentMethod.find_by(type: "Spree::PaymentMethod::Check", display_on: "both").id
      update!({
                  email: user.email,
                  bill_address_attributes: addr,
                  ship_address_attributes: addr,
                  payments_attributes: [{
                                            payment_method_id: pay
                                        }]
              })
      while state != 'complete' do
        next!
      end
    end
  end

  def unpaid_total
    update_totals - payments.where(state: 'completed').sum(:amount)
  end


  def generate_pay_params!(remote_ip, notify_url)
    raise 'order is paid.' if paid?
    pay = payments.where(state: 'checkout').last
    pay.update!(:amount => unpaid_total)
    res = WxPay::Service.invoke_unifiedorder({
                                                 body: number,
                                                 out_trade_no: pay.number,
                                                 total_fee: (pay.amount * 100).to_i,
                                                 spbill_create_ip: remote_ip,
                                                 notify_url: notify_url,
                                                 trade_type: 'JSAPI',
                                                 openid: user.openid
                                             })
    if res.success?
      WxPay::Service.generate_js_pay_req({prepayid: res['prepay_id'], noncestr: res['nonce_str']})
    else
      raise 'weixin unifiedorder invoke failure.'
    end
  end

  def tracking
    shipments.last.tracking if shipped? && shipments.any?
  end

  def order_state
    if state == 'complete'
      if payment_state.nil? and shipment_state.nil?
        '出错'
      elsif payment_state == 'balance_due'
        '待付款'
      elsif payment_state == 'paid' and shipment_state != 'shipped'
        '待完成'
      else
        '已完成'
      end
    else
      '未提交'
    end
  end


  private
  def address_params(name, phone, address)
    chars = name.chars
    country = Spree::Country.find_by(iso_name: 'CHINA')
    {
        "firstname": chars.first,
        "lastname": chars[1, chars.length - 1].join(''),
        "address1": address,
        "city": "...",
        "phone": phone,
        "zipcode": "510000",
        "state_id": country.states.first.id,
        "country_id": country.id
    }
  end

end
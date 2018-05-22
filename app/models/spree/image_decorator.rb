Spree::Image.class_eval do
  def mini_url
    attachment.url(:mini, false)
  end

  def small_url
    attachment.url(:small, false)
  end

  def product_url
    attachment.url(:product, false)
  end

  def large_url
    attachment.url(:large, false)
  end

  def find_dimensions
    self.attachment_width = 0
    self.attachment_height = 0
  end
end
Spree::Api::BaseController.class_eval do
  def load_user
    @current_api_user = current_spree_user || Spree.user_class.find_by(spree_api_key: api_key.to_s)
  end

  def render_ok(data = {}, msg = 'ok')
    render json: {data: data, message: msg}
  end

  def render_error(msg = 'ok')
    render json: {error: msg}
  end

end
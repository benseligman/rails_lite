class Flash < Session
  def initialize
    @new_values = {}
  end

  private

  def cookie_name
    "_rails_lite_app_flash"
  end

  def cookie_to_save
    @new_values
  end
end
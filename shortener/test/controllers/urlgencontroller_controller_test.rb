require 'test_helper'

class UrlgencontrollerControllerTest < ActionController::TestCase
  test "should get generate" do
    get :generate
    assert_response :success
  end

end

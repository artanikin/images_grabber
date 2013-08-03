require 'test_helper'

class ImgGrabControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get grabber" do
    get :grabber
    assert_response :success
  end

end

require 'test_helper'

class FundingsControllerTest < ActionController::TestCase
  setup do
    @funding = fundings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fundings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create funding" do
    assert_difference('Funding.count') do
      post :create, funding: { company_id: @funding.company_id, company_perma: @funding.company_perma, funding_amount: @funding.funding_amount, funding_code: @funding.funding_code, funding_currency: @funding.funding_currency, funding_date: @funding.funding_date }
    end

    assert_redirected_to funding_path(assigns(:funding))
  end

  test "should show funding" do
    get :show, id: @funding
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @funding
    assert_response :success
  end

  test "should update funding" do
    put :update, id: @funding, funding: { company_id: @funding.company_id, company_perma: @funding.company_perma, funding_amount: @funding.funding_amount, funding_code: @funding.funding_code, funding_currency: @funding.funding_currency, funding_date: @funding.funding_date }
    assert_redirected_to funding_path(assigns(:funding))
  end

  test "should destroy funding" do
    assert_difference('Funding.count', -1) do
      delete :destroy, id: @funding
    end

    assert_redirected_to fundings_path
  end
end

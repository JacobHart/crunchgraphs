require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase
  setup do
    @company = companies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:companies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company" do
    assert_difference('Company.count') do
      post :create, company: { crunch_url: @company.crunch_url, dead_date: @company.dead_date, founded_date: @company.founded_date, home_url: @company.home_url, industry_id: @company.industry_id, name: @company.name, perma: @company.perma }
    end

    assert_redirected_to company_path(assigns(:company))
  end

  test "should show company" do
    get :show, id: @company
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @company
    assert_response :success
  end

  test "should update company" do
    put :update, id: @company, company: { crunch_url: @company.crunch_url, dead_date: @company.dead_date, founded_date: @company.founded_date, home_url: @company.home_url, industry_id: @company.industry_id, name: @company.name, perma: @company.perma }
    assert_redirected_to company_path(assigns(:company))
  end

  test "should destroy company" do
    assert_difference('Company.count', -1) do
      delete :destroy, id: @company
    end

    assert_redirected_to companies_path
  end
end

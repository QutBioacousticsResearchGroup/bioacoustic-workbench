require 'spec_helper'

describe PermissionsController do
  describe "GET #index" do
    before(:each) do
      @response_body = json get: :index
    end

    it_should_behave_like  :an_idempotent_api_call, Permission
  end

  describe "GET #show" do
    before(:each) do
      @item = create(:permission)
      @response_body = json({ get: :show, id: @item.id })
    end

    it_should_behave_like  :an_idempotent_api_call, Permission, false
  end

  describe "GET #new" do
    before(:each) do
      @response_body = json get: :new
      @expected_hash = {
          :id => nil,
          :level => 'none',
          :logged_in => true,
          :permissionable_id => nil,
          :permissionable_type => nil,
          :user_id => nil,
          :updated_at => nil,
          :created_at => nil,
          :updater_id => nil,
          :creator_id => nil
      }
    end

    it_should_behave_like :a_new_api_call, Permission
  end

  describe "POST #create" do
    context "with valid attributes" do
      before(:each) do
        @initial_count = Permission.count
        test = convert_model(:create, :permission, build(:permission))
        @response_body = json(test)
      end

      it_should_behave_like :a_valid_create_api_call, Permission
    end

    context "with invalid attributes" do
      before(:each) do
        @initial_count = Permission.count
        test = convert_model(:create, :permission, nil)
        test[:permission][:logged_in] = false
        test[:permission][:user_id] = nil
        test[:permission][:level] = :owner
        @response_body = json(test)
      end

      it_should_behave_like :an_invalid_create_api_call, Permission, {:level=>["Anonymous users cannot have owners permission."]}
    end
  end

  describe "PUT #update" do
    context "with valid attributes" do
      before(:each) do
        @changed = create(:permission)
        @changed.level = :owner
        test = convert_model(:update, :permission, @changed)
        @response_body = json(test)
      end

      it_should_behave_like :a_valid_update_api_call, Permission, :level
    end

    context "with invalid attributes" do
      before(:each) do
        @initial = create(:permission)
        @old_value = @initial.level
        @initial.level = :does_not_exist
        @initial.logged_in = 'surprise!'
        test = convert_model(:update, :permission, @initial)
        @response_body = json(test)
      end

      it_should_behave_like :an_invalid_update_api_call, Permission, :level, {:level=>["is not included in the list", "can't be blank"], :user_id=>["Permissions cannot have a user id and not be logged in."]}
    end
  end

  describe "DELETE #destory" do
    it_should_behave_like :a_delete_api_call, Permission, :allow_delete #, :allow_archive

  end
end


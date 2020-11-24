require 'test_helper'

class SystemSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @system_setting = system_settings(:one)
  end

  test "should get index" do
    get system_settings_url
    assert_response :success
  end

  test "should get new" do
    get new_system_setting_url
    assert_response :success
  end

  test "should create system_setting" do
    assert_difference('SystemSetting.count') do
      post system_settings_url, params: { system_setting: { admin_notify_mail_to: @system_setting.admin_notify_mail_to, developer_notify_mail_to: @system_setting.developer_notify_mail_to, devise_mail_reply_to: @system_setting.devise_mail_reply_to, extra: @system_setting.extra, smtp_host: @system_setting.smtp_host, smtp_password: @system_setting.smtp_password, smtp_port: @system_setting.smtp_port, smtp_user: @system_setting.smtp_user, user_notify_mail_from: @system_setting.user_notify_mail_from } }
    end

    assert_redirected_to system_setting_url(SystemSetting.last)
  end

  test "should show system_setting" do
    get system_setting_url(@system_setting)
    assert_response :success
  end

  test "should get edit" do
    get edit_system_setting_url(@system_setting)
    assert_response :success
  end

  test "should update system_setting" do
    patch system_setting_url(@system_setting), params: { system_setting: { admin_notify_mail_to: @system_setting.admin_notify_mail_to, developer_notify_mail_to: @system_setting.developer_notify_mail_to, devise_mail_reply_to: @system_setting.devise_mail_reply_to, extra: @system_setting.extra, smtp_host: @system_setting.smtp_host, smtp_password: @system_setting.smtp_password, smtp_port: @system_setting.smtp_port, smtp_user: @system_setting.smtp_user, user_notify_mail_from: @system_setting.user_notify_mail_from } }
    assert_redirected_to system_setting_url(@system_setting)
  end

  test "should destroy system_setting" do
    assert_difference('SystemSetting.count', -1) do
      delete system_setting_url(@system_setting)
    end

    assert_redirected_to system_settings_url
  end
end

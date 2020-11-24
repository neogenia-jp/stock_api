# テストケースで共通的に使用するメソッド等の定義
module TestCaseCommonPlugins
  extend ActiveSupport::Concern

  included do
    self.use_transactional_tests = false
  end

  # # 一時的なActiveRecordのモデルクラスを作れる機能を追加
  # include TmpModelPlugin

  # test 定義時にオプションをつけられる機能を追加
  include TestWithOptionsPlugin

  # テストデータ設定
  include FactoryGirl::Syntax::Methods

  # データ掃除用
  include CleanupPlugin

  # 時間制御用
  include TimecopPlugin

  # 複数データ一括作成用
  include CreateDataHelperPlugin

  def assert_has_validation_error(m, msg_key, msg_partial)
    assert m.errors.messages.has_key?(msg_key), "#{msg_key}に関するvalidation errorが存在しません"
    assert_array_match /#{msg_partial}/, m.errors.full_messages, "Validationのエラーメッセージ #{m.errors.full_messages} の中に #{msg_partial} が含まれるエラーが存在しません。"
  end

  def assert_has_no_validation_error(m, msg_key)
    assert_not m.errors.messages.has_key?(msg_key), "#{msg_key}に関するvalidation errorが存在します [#{m.errors.messages[msg_key]}]"
  end
end

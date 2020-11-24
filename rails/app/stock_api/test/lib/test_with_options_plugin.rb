# 各テストの定義時にオプションを追加出来るようにする
# 通常テストは
# class TestClass < SomeSuperTestClass
#   test "test method name" do
#     # some test code
#   end
# end
#
# の形式で定義するが、teardown, setupでテスト単位での処理が行いにくい（テスト名でしか制御できない）ので、
# テスト定義時にオプションとしてhashを渡せるようにする機能を追加する
# class TestClass < SomeSuperTestClass
#   def setup
#     if run_options[:js]
#       # test定義時に:jsオプションが定義されているときだけの初期化処理
#     end
#   end
#
#   test "test method name", js: true, hoge: 10 do
#     some test code
#   end
# end
#
module TestWithOptionsPlugin
  extend ActiveSupport::Concern

  def run_options
    @@options_per_test[self.class][method_name.to_sym]
  end

  included do #ClassMethodsで定義すると@@options_per_testがクラスに紐付かなくなるのでincludedの中で特異クラスに定義
    @@options_per_test = {}
    class << self
      def test(name, options = {}, &block)
        super(name, &block)
        test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
        @@options_per_test[self] ||= {}
        @@options_per_test[self][test_name] = options.dup
      end
    end
  end
end

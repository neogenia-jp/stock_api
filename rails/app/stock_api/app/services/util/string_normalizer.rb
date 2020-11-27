module Util
  class StringNormalizer

    def self.normalize(name)
      str = soft_normalize name
      str.gsub!(/\s+/, '')           # 文字列中のスペースを削除
      str.delete!('・')              # 中黒を削除
      str.delete!('-')               # ハイフンを削除
      str.gsub!('株式会社', '(株)')
      str.gsub!('有限会社', '(有)')
      str.tr!('【】〔〕「」『』〈〉《》', '()()()()()()')   # かっこの正規化
      str.upcase!                    # 英小文字を大文字にする
      str.to_katakana!               # ひらがなをカタカナにする
      str
    end

    def self.soft_normalize(name)
      return '' unless name
      str = Unicode::nfkc name       # NFKC正規化
      str.strip!                     # 前後空白トリム
      str.tr!(%q|”’｀|, %q|"'`|)   # 全角記号の正規化
      str.gsub!(/\s+/, ' ')          # 文字列中のスペースを一つに圧縮
      str
    end
  end
end
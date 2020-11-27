class String

  HIRAGANAS = 'ぁ-んゔゕゖゝゞ'
  KATAKANAS = 'ァ-ンヴヵヶヽヾ'

  # ひらがな → カタカナ
  def to_katakana
    self.tr(HIRAGANAS, KATAKANAS)
  end

  # ひらがな → カタカナ（破壊的）
  def to_katakana!
    self.tr!(HIRAGANAS, KATAKANAS)
  end

  # カタカナ → ひらがな
  def to_hiragana
    self.tr(KATAKANAS, HIRAGANAS)
  end

  # カタカナ → ひらがな（破壊的）
  def to_hiragana!
    self.tr!(KATAKANAS, HIRAGANAS)
  end

end

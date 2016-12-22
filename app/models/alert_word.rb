class AlertWord < ActiveRecord::Base
  db_magic :connection => :community
  attribute :really_bad, Type::Boolean.new

  class AlertWordSearchResult < Struct.new(:alert_words, :really_bad_words)
    def any?
      alert_words.present? || really_bad_words.present?
    end

    def has_alert_words?
      alert_words.present?
    end

    def has_really_bad_words?
      really_bad_words.present?
    end
  end

  def really_bad
    read_attribute(:really_bad) == "\x01" ? true : false
  end

  def really_bad?
    really_bad
  end

  def self.all_words
    Rails.cache.fetch('alert_word/all_words', expires_in: 1.hour) do
      all_rows = on_db(:community).all
      really_bad_words = all_rows.select { |word| word.really_bad? }.map(&:word)
      alert_words = all_rows.select{ |word| word.really_bad? == false }.map(&:word)
      [ alert_words, really_bad_words ]
    end
  end

  def self.search(text)
    return AlertWordSearchResult.new unless text.present?

    alert_words, really_bad_words = all_words
    string = text.squeeze(' ')

    matched_alert_words = alert_words.select { |word| string =~ /\b(#{Regexp.quote(word)})\b.*/i }
    matched_really_bad_words = really_bad_words.select { |word| string =~ /\b(#{Regexp.quote(word)})\b.*/i }

    AlertWordSearchResult.new(
      matched_alert_words,
      matched_really_bad_words
    )
  end

end

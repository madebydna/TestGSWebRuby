# Inspired by https://gwt.googlesource.com/gwt/+/master/user/src/com/google/gwt/safehtml/shared/SafeHtmlUtils.java
class SafeHtmlUtils
  CONSTANT_HTML = '<a href="javascript:trusted()">click here &amp; enjoy</a>';
  HTML_ENTITY_REGEX = /\A[a-z]+\z|\A#[0-9]+\z|\A#x[0-9a-fA-F]+\z/

  def self.html_escape(s)
    result = s.dup
    result.gsub!('&', '&amp;')
    result.gsub!('<', '&lt;')
    result.gsub!('>', '&gt;')
    result.gsub!('"', '&quot;')
    result.gsub!("'", '&#39;')
    return result
  end

  # HTML-escapes a string, but does not double-escape HTML-entities already present in the string.
  def self.html_escape_allow_entities(text)
    escaped = ''
    text.split('&').each_with_index do |segment, index|
      # The first segment is never part of an entity reference, so we always escape it.
      # Note that if the input starts with an ampersand, we will get an empty segment before that.
      if index == 0
        escaped << html_escape(segment)
        next
      end

      entity_end = segment.index(';')
      if entity_end.present? && entity_end > 0 && !!(segment[0..(entity_end-1)].match(HTML_ENTITY_REGEX))
        # Append the entity without escaping.
        escaped << '&' << segment[0..entity_end]
        escaped << html_escape(segment[(entity_end+1)..-1])
      else
        # The segment did not start with an entity reference, so escape the whole segment.
        escaped << '&amp;' << html_escape(segment);
      end
    end

    # Ruby String's split function does not preserve an empty token at the end of the resulting array, as it does at
    # beginning of array
    # e.g. '&foo&'.split('&') =  ['', 'foo']
    escaped << '&amp;' if text[-1] == '&'

    return escaped
  end


end
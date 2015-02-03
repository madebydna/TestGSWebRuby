# Inspired by https://gwt.googlesource.com/gwt/+/master/user/src/com/google/gwt/safehtml/shared/SafeHtmlUtils.java
module SafeHtmlUtils
  module_function

  HTML_ENTITY_REGEX = /\A[a-z]+\z|\A#[0-9]+\z|\A#x[0-9a-fA-F]+\z/

  HTML_ENTITIES = {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    "'" => '&#39;'
  }.freeze

  def html_escape(s)
    regex_escaped_characters = HTML_ENTITIES.keys.map { |character| Regexp.escape(character) }
    search_regex = Regexp.new("[#{regex_escaped_characters.join('|')}]")
    s.gsub(search_regex, HTML_ENTITIES)
  end

  # HTML-escapes a string, but does not double-escape HTML-entities already present in the string.
  def html_escape_allow_entities(text)
    escaped = ''
    text.split('&').each_with_index do |token, index|
      # The first token is never part of an entity reference, so we always escape it.
      # Note that if the input starts with an ampersand, we will get an empty token before that.
      if index == 0
        escaped << html_escape(token)
        next
      end

      if string_matches_html_entity(token)
        # Append the entity without escaping.
        semicolon_position = token.index(';')
        entity = '&' << token[0..semicolon_position]
        escaped << entity
        # Escape everything after the entity
        rest_of_token = token[(semicolon_position+1)..-1]
        escaped << html_escape(rest_of_token)
      else
        # The token did not start with an entity reference, so escape the whole token.
        escaped << '&amp;' << html_escape(token);
      end
    end

    # Ruby String's split function does not preserve an empty token at the end of the resulting array, as it does at
    # beginning of array
    # e.g. '&foo&'.split('&') =  ['', 'foo']
    escaped << '&amp;' if text[-1] == '&'

    return escaped
  end

  def string_matches_html_entity(token)
    semicolon_position = token.index(';')
    if semicolon_position.present? && semicolon_position > 0
      stuff_before_semicolon = token[0..(semicolon_position-1)]
      return !!(stuff_before_semicolon.match(HTML_ENTITY_REGEX))
    end
    return false
  end


end
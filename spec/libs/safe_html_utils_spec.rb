require 'spec_helper'

# Inspired by https://gwt.googlesource.com/gwt.git/+/9453549842ae10f24d6299a52897d423bd8e0b7d/user/test/com/google/gwt/safehtml/shared/GwtSafeHtmlUtilsTest.java
describe SafeHtmlUtils do

  describe '#html_escape' do
    it 'should not escape "foobar"' do
      escaped = SafeHtmlUtils.html_escape('foobar')
      expect(escaped).to eq('foobar')
      expect(SafeHtmlUtils.html_escape(escaped)).to eq(escaped)
    end

    it 'should escape ampersands' do
      escaped = SafeHtmlUtils.html_escape('foo&bar')
      expect(escaped).to eq('foo&amp;bar')
    end

    it 'should escape ampersands and brackets' do
      escaped = SafeHtmlUtils.html_escape('fo<o&b<em>ar')
      expect(escaped).to eq('fo&lt;o&amp;b&lt;em&gt;ar')
    end

    it 'should escape meta characters' do
      escaped = SafeHtmlUtils.html_escape('f"bar \'<&em><e/m>oo&bar')
      expect(escaped).to eq('f&quot;bar &#39;&lt;&amp;em&gt;&lt;e/m&gt;oo&amp;bar')
    end

    it 'should not escape "a"' do
      escaped = SafeHtmlUtils.html_escape('a')
      expect(escaped).to eq('a')
    end

    {
      '&' => '&amp;',
      '<' => '&lt;',
      '>' => '&gt;',
      '"' => '&quot;',
      "'" => '&#39;'
    }.each_pair do |character, entity|
      it "should escape character:  #{character} to #{entity}" do
        escaped = SafeHtmlUtils.html_escape(character)
        expect(escaped).to eq(entity)
      end
    end
  end

  describe '#html_escape_allow_entities' do
    inputs_and_outputs = {
      'f"bar \'<&em><e/m>oo&bar' => 'f&quot;bar &#39;&lt;&amp;em&gt;&lt;e/m&gt;oo&amp;bar',
      '& foo &lt;' => '&amp; foo &lt;',
      '<foo> &amp; <em> bar &#39; baz' => '&lt;foo&gt; &amp; &lt;em&gt; bar &#39; baz',
      '&foo &&amp; bar &#39; baz&' => '&amp;foo &amp;&amp; bar &#39; baz&amp;',
      '&a mp;&;&x;&#;&#x;' => '&amp;a mp;&amp;;&x;&amp;#;&amp;#x;'
    }

    inputs_and_outputs.each_pair do |input, output|
      it "should escape  '#{input}'  to  '#{output}'" do
        escaped = SafeHtmlUtils.html_escape_allow_entities(input)
        expect(escaped).to eq(output)
        expect(SafeHtmlUtils.html_escape_allow_entities(escaped)).to eq(escaped)
      end

      it "should be idempotent when escaping  #{input}" do
        escaped = SafeHtmlUtils.html_escape_allow_entities(input)
        expect(SafeHtmlUtils.html_escape_allow_entities(escaped)).to eq(escaped)
      end
    end
  end

end


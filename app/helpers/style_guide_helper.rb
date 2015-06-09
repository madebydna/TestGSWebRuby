module StyleGuideHelper
  STYLE_GUIDE_LAYOUT_FILES_DIRECTORY = 'admin/style_guide/style_guide_layout_files'

  def render_chapter_title
    render "#{STYLE_GUIDE_LAYOUT_FILES_DIRECTORY}/chapter_title"
  end

  def begin_chapter_content(&block)
    render layout: "#{STYLE_GUIDE_LAYOUT_FILES_DIRECTORY}/chapter_content", &block
  end

  def begin_section_with_title(title, &block)
    render layout: "#{STYLE_GUIDE_LAYOUT_FILES_DIRECTORY}/section", locals: { title: title }, &block
  end

  def begin_section_description(&block)
    render layout: "#{STYLE_GUIDE_LAYOUT_FILES_DIRECTORY}/section_description", &block
  end

  def begin_section_content(&block)
    render layout: "#{STYLE_GUIDE_LAYOUT_FILES_DIRECTORY}/section_content", &block
  end
end

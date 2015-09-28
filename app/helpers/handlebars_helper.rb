module HandlebarsHelper

  TEMPLATES_DIR = 'app/views/handlebars/'
  EXTENSION = '.html.erb'

  # Handles files and directories.
  # On page load the GS.handlebars.registerPartials function will
  # register all included templates as partials that can be used with the
  # {{> partialName}} syntax.
  # The partialName will be the same as a rails partial render, e.g.
  # app/views/handlebars/community_scorecards/_table.html.erb is rendered
  # with {{> community_scorecards/table}}.
  def include_handlebars_template(template_path)
    template_path.sub!(/^\//, '')
    templates_for(template_path).map do |template|
      render partial: 'shared/handlebars_wrapper', locals: {
        template: template,
        id: path_as_template_id(template),
      }
    end.join.html_safe
  end
  alias :include_handlebars_templates :include_handlebars_template

  def t_scope_for(file)
    file
      .partition(TEMPLATES_DIR).last # Path after TEMPLATE_DIR
      .gsub('/','.')                  # Directories are hierarchies of scope
      .gsub('._','.')                 # Partials aren't prefixed with underscores
      .sub('.html.erb','')           # Remove file extension
  end

  protected

  def templates_for(template_path)
    files_for(template_path).map do |file|
      partial_name_for(file)
    end
  end

  def partial_name_for(file)
    file.sub(TEMPLATES_DIR, '').sub(/\/_/, '/').sub(/^_/, '').sub(EXTENSION, '')
  end

  def files_for(template_path)
    Dir[TEMPLATES_DIR + directory_or_file(template_path) + EXTENSION]
  end

  def directory_or_file(template_path)
    if template_path.ends_with?('/')
      "#{template_path}*"
    elsif template_path.include?('/')
      template_path.sub('/', '/_')
    else
      '_' + template_path
    end
  end

  def path_as_template_id(template_path)
    template_path.gsub('/', '-')
  end
end

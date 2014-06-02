class Publication < ActiveRecord::Base
  self.table_name = 'publications'
  db_magic connection: :gscms_pub

  include ActionView::Helpers::SanitizeHelper

  after_find { self.content = ActiveSupport::JSON.decode(content) unless content.empty? }

  def self.find_by_ids(*ids)
    ids.inject(Hash.new) { |h, id| h.merge!({id => find(id)}) }
  end

  def create_attributes_for(*attributes)
    attributes.each do |attribute|
      create_attribute(attribute, content[attribute])
    end
  end

  private

  def create_attribute(attribute, value = nil)
    create_method("#{attribute}=".to_sym) { |val| instance_variable_set("@" + attribute, val) }
    create_method(attribute.to_sym) { instance_variable_get("@" + attribute) }
    method("#{attribute}=".to_sym).call(value)
  end

  def create_method(name, &method)
    self.class.send(:define_method, name, &method)
  end

  # def bench_find_each
  # 	Benchmark.measure { Publication.where(:content_type => 'article').find_each { | article | article.content } }
  # end
  #
  # def bench_all
  # 	Benchmark.measure { Publication.where(:content_type => 'article').all { | article | article.id } }
  # end

  # def strip_tags! 
  # end

  # def build_body
  # end
end
SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)

def usage
  abort "\nUSAGE: rails runner script/generate_pyoc_pdf  [state]:[collection_id]:is_high_school:[page_start]
or
\nUSAGE: rails runner script/generate_pyoc_pdf  [state]:[collection_id]:is_k8:[page_start]
Ex: rails runner script/generate_pyoc_pdf wi:2:is_high_school:0
rails runner script/generate_pyoc_pdf wi:2:is_k8:9
For Spanish
rails runner script/generate_pyoc_pdf wi:2:is_k8:9:1
"
end
def find_school_to_be_printed(state,collection_id,high_school_or_k8)
  if state.present? && collection_id.present? && high_school_or_k8.present?  && high_school_or_k8=='is_high_school'
    db_schools_full = School.on_db(state).where(active: true).order(name: :asc)
    @db_schools = []
    db_schools_full.each do |school|
      # puts school.collection.id
      if school.collection.present? && school.collection.id == collection_id.to_i && PyocController.new.is_high_school(school)
        @db_schools.push(school)
      end
    end
  elsif state.present? && collection_id.present? && high_school_or_k8.present?  && high_school_or_k8=='is_k8'
    db_schools_full = School.on_db(state).where(active: true).order(name: :asc)
    @db_schools = []
    db_schools_full.each do |school|
      if school.collection.present? && school.collection.id == collection_id.to_i && PyocController.new.is_k8(school)
        @db_schools.push(school)
      end
    end
  elsif state.present? && !collection_id.present?
    @db_schools = School.on_db(state_param).where(active: true).order(name: :asc)

  end
end
if ARGV.present? && ARGV.length ==4
  @state=ARGV[0]
  @collection_id=ARGV[1]
  @high_school_or_k8=ARGV[2]
  @page_start=ARGV[3]
elsif ARGV.present? && ARGV.length ==5
  @state=ARGV[0]
  @collection_id=ARGV[1]
  @high_school_or_k8=ARGV[2]
  @page_start=ARGV[3]
  @is_spanish=ARGV[4]
else
  usage
end

find_school_to_be_printed(@state,@collection_id,@high_school_or_k8)


@schools_decorated_with_cache_results=PyocController.new.prep_data_for_pdf(@db_schools)


pdf = PyocPdf.new(@schools_decorated_with_cache_results, @high_school_or_k8=='is_k8'? true :false , @high_school_or_k8=='is_high_school'?true:false, @page_start,@is_spanish.present? ? true : false)
pdf.render_file  Time.now.strftime("%m%d%Y")+'_'+@state+'_'+@collection_id+'_'+@high_school_or_k8+'_pyoc.pdf'


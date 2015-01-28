class Benchmarker
  DEFAULT_WIDTH = 10 # Helps with console formatting

  def time_process!(method_list)
    Benchmark.bmbm(DEFAULT_WIDTH) do |x|
      method_list.each do |method|
        x.report(method[:name]) { method[:call].call }
      end
    end
  end

  def process_result(time, row_count)
    {
        row_count: row_count,
        time: time
    }
  end

  def write_out_results(file_name, results, result_headers=nil)
    result_headers ||= results.first.keys
    output = result_headers.join(',') + "\n"

    results.each do |result|
      row = result_headers.map { |v| result[v] }.join(',') + "\n"
      output << row
    end

    f_name = Time.now.to_i.to_s + file_name
    File.write(f_name, output)
  end

end
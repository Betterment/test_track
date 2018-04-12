module FilePatternSpecHelper
  def check_files_for_pattern(file_pattern, pattern)
    result = []
    Dir[*file_pattern].each do |file|
      next unless File.file?(file)
      File.open(file, 'r:utf-8') do |f|
        f.each_line.with_index do |line, index|
          result << "#{file}:#{index + 1}" if line.match(pattern)
        end
      end
    end
    result
  end
end

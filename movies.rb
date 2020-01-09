file_name = ARGV.first || 'movies.txt'
file = File.open file_name

file.each do |line|
  arr = line.split('|')
  title = arr[1]

  if title.include? 'Max'
    stars = ('*' * ((arr[7].to_f * 10).to_i - 80))
    puts "Title: #{title}, Rate: #{stars}"
  end
end

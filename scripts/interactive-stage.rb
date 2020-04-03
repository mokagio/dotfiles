def colorize(text, color = "default", bgColor = "default")
    colors = {"default" => "38","black" => "30","red" => "31","green" => "32","brown" => "33", "blue" => "34", "purple" => "35",
     "cyan" => "36", "gray" => "37", "dark gray" => "1;30", "light red" => "1;31", "light green" => "1;32", "yellow" => "1;33",
      "light blue" => "1;34", "light purple" => "1;35", "light cyan" => "1;36", "white" => "1;37"}
    bgColors = {"default" => "0", "black" => "40", "red" => "41", "green" => "42", "brown" => "43", "blue" => "44",
     "purple" => "45", "cyan" => "46", "gray" => "47", "dark gray" => "100", "light red" => "101", "light green" => "102",
     "yellow" => "103", "light blue" => "104", "light purple" => "105", "light cyan" => "106", "white" => "107"}
    color_code = colors[color]
    bgColor_code = bgColors[bgColor]
    return "\033[#{bgColor_code};#{color_code}m#{text}\033[0m"
end

def interactive_stage
  # If we wanted this to be portable on Windows too, this
  # could be the place to start:
  # https://stackoverflow.com/questions/3170553/how-can-i-clear-the-terminal-in-ruby#answer-38531280
  system('clear')
  available_files = `git status --short`.lines

  available_files.each_with_index do |f, index|
    message = "#{index + 1}) #{f}"
    if f.start_with? ' M'
      print colorize(message, "light green")
    elsif f.start_with? 'M '
      print colorize(message, "purple")
    elsif f.start_with? ' A'
      print colorize(message, "green")
    elsif f.start_with? 'A '
      print colorize(message, "purple")
    elsif f.start_with? ' C'
      print colorize(message, "light green")
    elsif f.start_with? 'C '
      print colorize(message, "purple")
    elsif f.start_with? '??'
      print colorize(message, "brown")
    else
      puts message
    end
  end

  print 'Type index of file to stage, or press enter to finish: '
  input = STDIN.gets.chomp!

  if input.empty?
    puts '👋'
    exit 0
  end

  # This needs more input sanitization...

  selected_file = available_files[input.to_i - 1]

  if selected_file.nil?
    puts "#{input} is not a valid index"
    # Reload
    return interactive_stage
  end

  path = selected_file.split(' ').last

  `git add #{path}`

  interactive_stage
end

interactive_stage

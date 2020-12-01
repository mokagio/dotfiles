# Get the Git log clip with the commits to cherry-pick from the pasteboard.
git_log_input = `pbpaste`

# Extract the commit SHAs from the input.
#
# Expected format from the custom git log output:
#
# * b633fd0 - ...
# * 9ea54f4 - ...
# * ...
commits = git_log_input.lines.map { |l| l.split(' ')[1] }

# When cherry-picking, we need to start from the _oldest_ commit
commits = commits.reverse

commits.each_with_index do |sha, index|
  suffix = "#{sha} (#{index + 1} of #{commits.length})"
  puts "🍒 Cherry picking #{suffix}"

  system("git cherry-pick #{sha}")

  if $?.exitstatus != 0
    puts "😟 cherry picking failed for #{suffix}"
    puts "Once you fix it copy the following output and run the script again to continue the process"
    puts "TODO!"
    exit 1
  end
end

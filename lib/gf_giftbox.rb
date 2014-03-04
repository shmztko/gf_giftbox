require File.expand_path(File.dirname(__FILE__)) + '/gf_giftbox/gf_accessor'
require File.expand_path(File.dirname(__FILE__)) + '/gf_giftbox/gf_database'

def show_help(message)
  puts """
      #{message}
      
      USAGE:
        list    -> list all girl friends in giftbox.
        persist -> persist all girl friends in giftbox.
        clean   -> clean all girl friends from local database.
    """
end


if __FILE__ == $0

  if ARGV.empty?
    show_help 'Argument required.'

  elsif ARGV[0] == 'list'
    
    GFAccessor.new.list.each do |item|
      puts "#{item[:id]}  #{item[:name]}    #{item[:rarity]}  #{item[:amount]}  #{item[:image_src]}"
    end

  elsif ARGV[0] == 'persist'
    GFAccessor.new.persist

  elsif ARGV[0] == 'clean'
    GFAccessor.new.clean

  else
    show_help 'Invalid argument.'
  end
end


class WebhooksController < ApplicationController
  
  def create_conference_succeeded
    puts "*********************"
    puts "Create conference succeeded"
    puts params
    puts "*********************"
  end

  def conference_ended
    puts "*********************"
    puts "Conference ended"
    puts params
    puts "*********************"
  end

end
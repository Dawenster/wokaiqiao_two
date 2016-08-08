class WebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token, :authenticate_user!
  
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
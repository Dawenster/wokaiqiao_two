class WebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token, :authenticate_user!

  def joined_conference
    call = Call.find_by_conference_call_participant_code(params[:confid])
    if call.present?
      start_time = Cloopen::Controller.parse_time(params[:jointime])
      call.update(started_at: start_time)
    end

    render :nothing => true, :status => 200
  end
  
  def conference_ended
    call = Call.find_by_conference_call_participant_code(params[:confid])
    if call.present?
      end_time = Cloopen::Controller.parse_time(params[:deltime])
      call.update(ended_at: end_time)
    end

    render :nothing => true, :status => 200
  end

end
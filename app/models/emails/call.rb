module Emails
  class Call

    def self.send_confirmation_to_user(user, expert, call)
      begin
        obj = Emails::Setup.send_with_us_obj

        result = obj.send_email(
          "tem_grdpsHAakdFUHsKcz25nQE",
          { address: user.email },
          data: {
            user_name: user.name,
            user_email: user.email,
            manage_calls_link: "#",
            expert_name: expert.name,
            expert_expertise: expert.expertise,
            expert_picture: expert.picture.url(:medium),
            expert_location: expert.location,
            expert_past_work: expert.past_work,
            expert_education: expert.list_education,
            requested_date_time_one: ChineseTime.display(call.offer_time_one),
            requested_date_time_two: ChineseTime.display(call.offer_time_two),
            requested_date_time_three: ChineseTime.display(call.offer_time_three),
            call_description: call.description,
            rate_per_min: expert.rate_per_minute,
            estimated_duration_in_min: call.est_duration_in_min
          }
        )
      rescue => e
        puts "Error - #{e.class.name}: #{e.message}"
      end
    end

  end
end
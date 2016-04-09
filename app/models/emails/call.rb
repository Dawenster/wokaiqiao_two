module Emails
  class Call

    def self.send_confirmation_to_user(data)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = data[:user]
        expert = data[:expert]
        call = data[:call]

        result = obj.send_email(
          "tem_grdpsHAakdFUHsKcz25nQE",
          { address: user.email },
          data: {
            user_name: user.name,
            user_email: user.email,
            manage_calls_link: data[:link_to_manage_calls],
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

    def self.send_confirmation_to_expert(data)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = data[:user]
        expert = data[:expert]
        call = data[:call]

        result = obj.send_email(
          "tem_75EqK2QPeQSV2aCkwL3qGa",
          { address: user.email },
          data: {
            user_name: user.name,
            manage_calls_link: data[:link_to_manage_calls],
            expert_name: expert.name,
            requested_date_time_one: ChineseTime.display(call.offer_time_one),
            requested_date_time_two: ChineseTime.display(call.offer_time_two),
            requested_date_time_three: ChineseTime.display(call.offer_time_three),
            link_to_accept_call_one: data[:link_to_accept_call_one],
            link_to_accept_call_two: data[:link_to_accept_call_two],
            link_to_accept_call_three: data[:link_to_accept_call_three],
            call_description: call.description,
            rate_per_min: expert.rate_per_minute,
            estimated_duration_in_min: call.est_duration_in_min
          }
        )
      rescue => e
        puts "Error - #{e.class.name}: #{e.message}"
      end
    end

    def self.send_confirmation_to_admin(data, rails_admin_path, general_email)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = data[:user]
        expert = data[:expert]
        call = data[:call]

        result = obj.send_email(
          "tem_JDWkoFffepCB9dqtGhdqt",
          { address: general_email },
          data: {
            user_name: user.name,
            expert_name: expert.name,
            call_description: call.description,
            rate_per_min: expert.rate_per_minute,
            estimated_duration_in_min: call.est_duration_in_min,
            rails_admin_path: rails_admin_path
          },
          cc: Emails::User.admin_emails
        )
      rescue => e
        puts "Error - #{e.class.name}: #{e.message}"
      end
    end

  end
end
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

    def self.send_cancel_notice(call, link_to_manage_calls)
      begin
        obj = Emails::Setup.send_with_us_obj
        canceller = call.user_that_cancelled
        cancellee = call.cancellee

        result = obj.send_email(
          "tem_ssrtGZFeqUeKoKCA6Ww43L",
          { address: cancellee.email },
          data: {
            canceller_name: canceller.name,
            cancellee_name: cancellee.name,
            cancellation_reason: call.cancellation_reason,
            manage_calls_link: link_to_manage_calls,
            hours_buffer: ::Call::CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED,
            minutes_to_charge: ::Call::MINUTES_TO_CHARGE_FOR_CANCELLATION,
            cancelled_in_time: call.apply_cancellation_fee? ? "否" : "是", # The email asks the question "did the person cancel in time?"
            amount_to_collect: call.cancellation_fee,
            cancellee_is_expert: cancellee == call.expert
          }
        )
      rescue => e
        puts "Error - #{e.class.name}: #{e.message}"
      end
    end

    def self.send_cancellation_notice_to_admin(call, rails_admin_path, general_email)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = call.user
        expert = call.expert
        canceller = call.user_that_cancelled

        result = obj.send_email(
          "tem_8sPJV9UUwaDDs4kPJvwMDA",
          { address: general_email },
          data: {
            user_name: user.name,
            expert_name: expert.name,
            canceller_name: canceller.name,
            cancellation_reason: call.cancellation_reason,
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
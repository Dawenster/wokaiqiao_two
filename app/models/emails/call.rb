module Emails
  class Call

    def self.send_confirmation_of_call_request_to_user(data)
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
            expert_expertise: expert.description,
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
        Rollbar.error(e)
      end
    end

    def self.send_initial_request_to_expert(data)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = data[:user]
        expert = data[:expert]
        call = data[:call]

        result = obj.send_email(
          "tem_75EqK2QPeQSV2aCkwL3qGa",
          { address: expert.email },
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
            estimated_duration_in_min: call.est_duration_in_min,
            hours_buffer: ::Call::CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED,
            minutes_to_charge: ::Call::MINUTES_TO_CHARGE_FOR_CANCELLATION
          }
        )
      rescue => e
        Rollbar.error(e)
      end
    end

    def self.send_request_notification_to_admin(data, rails_admin_path, general_email)
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
        Rollbar.error(e)
      end
    end

    def self.edit_request(data)
      begin
        obj = Emails::Setup.send_with_us_obj
        call = data[:call]
        receiver = data[:receiver]
        editing_user = data[:editing_user]

        result = obj.send_email(
          "tem_9Pzvm4JTewGzff7V8KJkGd",
          { address: receiver.email },
          data: {
            editing_user_name: editing_user.name,
            receiver_name: receiver.name,
            expert_picture: call.expert.picture.url(:medium),
            manage_calls_link: data[:link_to_manage_calls],
            requested_date_time_one: ChineseTime.display(call.offer_time_one),
            requested_date_time_two: ChineseTime.display(call.offer_time_two),
            requested_date_time_three: ChineseTime.display(call.offer_time_three),
            link_to_accept_call_one: data[:link_to_accept_call_one],
            link_to_accept_call_two: data[:link_to_accept_call_two],
            link_to_accept_call_three: data[:link_to_accept_call_three],
            call_description: call.description,
            rate_per_min: call.expert.rate_per_minute,
            estimated_duration_in_min: call.est_duration_in_min,
            hours_buffer: ::Call::CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED,
            minutes_to_charge: ::Call::MINUTES_TO_CHARGE_FOR_CANCELLATION
          }
        )
      rescue => e
        Rollbar.error(e)
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
        Rollbar.error(e)
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
        Rollbar.error(e)
      end
    end

    def self.send_call_acceptance_confirmation(call, link_to_manage_calls, receiver_text)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = call.user
        expert = call.expert
        receiver = receiver_text == ::Call::EXPERT_ACCEPTOR_TEXT ? expert : user
        other_person = receiver_text == ::Call::EXPERT_ACCEPTOR_TEXT ? user : expert
        dial_in_code = call.conference_call_participant_code
        # dial_in_code += "，主持启动密码：#{call.conference_call_admin_code}" if receiver_text == ::Call::EXPERT_ACCEPTOR_TEXT

        result = obj.send_email(
          "tem_PB3bXhdYEUde2zND63Y8yR",
          { address: receiver.email },
          data: {
            receiver_name: receiver.name,
            other_person_name: other_person.name,
            conference_number: call.conference_call_number,
            conference_participant_code: dial_in_code,
            link_to_manage_calls: link_to_manage_calls,
            scheduled_date_time: ChineseTime.display(call.scheduled_at),
            expert_expertise: expert.description,
            expert_picture: expert.picture.url(:medium),
            expert_location: expert.location,
            expert_past_work: expert.past_work,
            expert_education: expert.list_education,
            call_description: call.description,
            rate_per_min: expert.rate_per_minute,
            estimated_duration_in_min: call.est_duration_in_min,
            hours_buffer: ::Call::CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED,
            minutes_to_charge: ::Call::MINUTES_TO_CHARGE_FOR_CANCELLATION,
            receiver_is_user: receiver == user,
            user_title: user.title,
            user_short_description: user.description
          }
        )
      rescue => e
        Rollbar.error(e)
      end
    end

    def self.send_call_acceptance_confirmation_to_admin(call, rails_admin_path, general_email)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = call.user
        expert = call.expert

        result = obj.send_email(
          "tem_pnnkV8KaWSK7gF4aYvbK6f",
          { address: general_email },
          data: {
            user_name: user.name,
            expert_name: expert.name,
            scheduled_date_time: ChineseTime.display(call.scheduled_at),
            call_description: call.description,
            rails_admin_path: rails_admin_path
          },
          cc: Emails::User.admin_emails
        )
      rescue => e
        Rollbar.error(e)
      end
    end

    def self.send_call_completion_to_user(call, amount_already_collected, original_payment, credits_applied)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = call.user
        expert = call.expert
        links = Emails::Links.new
        manage_calls_link = links.calls_url(auth_token: user.auth_token)
        rate_with_rating_link = links.rate_with_rating_call_url(call, auth_token: user.auth_token)

        result = obj.send_email(
          "tem_LFr5ctYwEhR5W5MKyNS5mc",
          { address: user.email },
          data: {
            user_name: user.name,
            expert_name: expert.name,
            rate_per_min: expert.rate_per_minute,
            scheduled_date_time: ChineseTime.display(call.scheduled_at),
            duration_in_min: call.actual_duration_in_min,
            amount_to_collect: original_payment,
            manage_calls_link: manage_calls_link,
            rate_with_rating_link: rate_with_rating_link,
            credit_amount: credits_applied,
            amount_already_collected: amount_already_collected
          }
        )
      rescue => e
        Rollbar.error(e)
      end
    end

    def self.send_call_completion_to_expert(call)
      begin
        obj = Emails::Setup.send_with_us_obj
        user = call.user
        expert = call.expert
        links = Emails::Links.new
        manage_calls_link = links.calls_url(auth_token: expert.auth_token)
        rate_with_rating_link = links.rate_with_rating_call_url(call, auth_token: expert.auth_token)

        result = obj.send_email(
          "tem_6sB2KctZEqnZJEcrskdGfm",
          { address: expert.email },
          data: {
            user_name: user.name,
            expert_name: expert.name,
            rate_per_min: expert.rate_per_minute,
            scheduled_date_time: ChineseTime.display(call.scheduled_at),
            duration_in_min: call.actual_duration_in_min,
            total_collected: call.cost,
            wokaiqiao_collected: "#{call.admin_fee} (#{call.payout.admin_fee_percentage}%)",
            amount_earned: call.expert_payout,
            manage_calls_link: manage_calls_link,
            rate_with_rating_link: rate_with_rating_link
          }
        )
      rescue => e
        Rollbar.error(e)
      end
    end

  end
end
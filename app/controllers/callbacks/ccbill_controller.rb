module Callbacks
  class CcbillsController < ApplicationController
    before_action :check_ccbill_callback, only: :create

    # GET: Redirect from payment system after approval/deny.
    def show
      case response_params[:mppResponse]
      when 'CheckoutSuccess'
        flash[:notice] = "Payment was successfully paid"
      when 'CheckoutFail'
        flash[:alert] = "Payment was declined. We're sorry"
      else
        ExceptionSender.new('Payment response', { response_params: response_params }).notify
        fail 'Unknown mmpResponse'
      end

      redirect_to root_url
    end

    # POST: Post Back
    def create
      postback = CCBill::Postback.new(response_params)

      if postback.approval?
        ActiveRecord::Base.transaction do
          # Do something "Approval" postback.
        end
      else
        # Do something "Deny" postback.
      end

      head :no_content
    end
  end
end

module Callbacks
  class CcbillsController < ApplicationController

    # GET: Redirect from payment system after approval/deny.
    def show
      case params[:mppResponse]
      when 'CheckoutSuccess'
        flash[:notice] = "Payment was successfully paid"
      when 'CheckoutFail'
        flash[:alert] = "Payment was declined. We're sorry"
      else
        fail 'Unknown mmpResponse'
      end

      redirect_to root_url
    end

    # POST: Webhooks
    def create
      postback = CCBill::Postback.new(response_params)

      if postback.approval?
        # Do something "Approval" postback.
      else
        # Do something "Deny" postback.
      end

      head :no_content
    end

    private

    def response_params
      @response_params ||= params.except(:controller, :action).to_unsafe_h
    end
  end
end

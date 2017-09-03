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
      begin
        # Your code goes here.
      rescue StandardError => error
        # I assume we should put `rescue` statement because CCBill will call our server again and again untill he will receive 200
        # When there was failure of sending webhooks or the system was under maintenance at the moment.
      end

      head :ok
    end

  end
end

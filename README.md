# GEM IS UNDER CONSNSTRUCTION!

Please Mail me if any - 'dmytro.vasin@gmail.com'

# CCBill SDK for Ruby

Unofficial CCBill SDK for Ruby.

...


## Getting started

```ruby
gem 'ccbill_ruby'
```

Then run `bundle install`

Next, you need to run the generator:

```console
$ rails generate ccbill:install
```

This will create a controller (if one does not exist) and configure it with the default actions. The generator also configures your config/routes.rb file to point to the CCBill controller.

### Controller and methods:

Before reading this part - please read [Setup guide](#setup-guide)

`ccbill-install` will generate next:

config/routes.rb
```ruby
  namespace :callbacks do
    resource :ccbill, only: [:show, :create]
  end
```

app/controllers/callbacks/ccbills_controller.rb
```ruby
module Callbacks
  class CcbillsController < ApplicationController
    # before_action :check_ccbill_callback, only: :create

    # GET: Redirect from payment system after approval/deny.
    def show
      case response_params[:mppResponse]
      when 'CheckoutSuccess'
        flash[:notice] = "Payment was successfully paid"
      when 'CheckoutFail'
        flash[:alert] = "Payment was declined. We're sorry"
      else
        fail 'Unknown mmpResponse'
      end

      redirect_to root_url
    end

    # POST: Post Back
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

```

## Setup guide

TODO:



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

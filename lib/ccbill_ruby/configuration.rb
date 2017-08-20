module CCBill
  class Configuration
    TEST_ENDPOINT = 'https://sandbox-api.ccbill.com/wap-frontflex/flexforms/'
    LIVE_ENDPOINT = 'https://api.ccbill.com/wap-frontflex/flexforms/'

    attr_accessor :mode

    attr_accessor :salt
    attr_accessor :default_currency

    attr_accessor :account
    attr_accessor :sub_account

    attr_accessor :flexform_id
    attr_accessor :test_endpoint
    attr_accessor :live_endpoint

    def initialize
      @mode = :test
      @default_currency = '840' # USD

      @test_endpoint = TEST_ENDPOINT
      @live_endpoint = LIVE_ENDPOINT
    end

    def test?
      mode.to_sym == :test
    end

    def endpoint
      if test?
        test_endpoint
      else
        live_endpoint
      end
    end

  end
end

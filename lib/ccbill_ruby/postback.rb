module CCBill
  class Postback
    attr_accessor :response_params

    def initialize(response_params = {})
      self.response_params = response_params
    end

    def verified?
      # NOTE: https://github.com/DmytroVasin/ccbill_ruby#response-digest-value
      return true if CCBill.configuration.test?

      response_params['dynamicPricingValidationDigest'] == encode_digest_response
    end

    private

    def denied?
      ['failureCode', 'failureReason'].any? do |key|
        !response_params[key].to_s.strip.empty?
      end
    end

    def encode_digest_response
      verify_fields = if denied?
        [
          response_params['transactionId'],
          '0',
          CCBill.configuration.salt
        ]
      else
        [
          response_params['subscriptionId'],
          '1',
          CCBill.configuration.salt
        ]
      end

      Digest::MD5.hexdigest(verify_fields.join)
    end
  end
end

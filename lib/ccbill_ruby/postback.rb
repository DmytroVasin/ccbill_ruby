module CCBill
  class Postback
    attr_accessor :response_params

    def initialize(response_params = {})
      self.response_params = response_params
    end

    def approval?
      !denial?
    end

    def denial?
      [:reasonForDeclineCode, :reasonForDecline, :denialId].any? do |key|
        !response_params[key].to_s.strip.empty?
      end
    end

    def verified?
      fail 'NOTE: Does not work on test env - Did not check for production.'
      response_params[:responseDigest] == encode_digest_response
    end

    private

    def encode_digest_response
      verify_fields = if approval?
        [
          response_params[:subscription_id],
          '1',
          CCBill.configuration.salt
        ]
      else
        [
          response_params[:denialId],
          '0',
          CCBill.configuration.salt
        ]
      end

      Digest::MD5.hexdigest(verify_fields.join)
    end
  end
end

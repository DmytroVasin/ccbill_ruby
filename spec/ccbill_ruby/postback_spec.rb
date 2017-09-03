require 'json'
require 'ccbill_ruby'

describe CCBill::Postback do
  context '#verified? within test mode' do
    before do
      CCBill.configure do |config|
        config.salt = '99999'
        config.mode = :test
      end
    end

    # NOTE: https://github.com/DmytroVasin/ccbill_ruby#response-digest-value
    it 'return true value on success response' do
      success_params.merge!({
        'subscriptionId' => 'fake_subscription',
        'dynamicPricingValidationDigest' => 'fake_digest'
      })

      postback = CCBill::Postback.new(success_params)
      expect(postback.verified?).to be_truthy
    end

    it 'return true value on deny response' do
      failure_params.merge!({
        'transactionId' => 'fake_subscription',
        'dynamicPricingValidationDigest' => 'fake_digest'
      })

      postback = CCBill::Postback.new(failure_params)
      expect(postback.verified?).to be_truthy
    end
  end

  context '#verified? within non test mode' do
    before do
      CCBill.configure do |config|
        config.salt = '99999'
        config.mode = :non_test
      end
    end

    context 'success response' do
      it 'returns true for correct digest' do
        correct_digest = Digest::MD5.hexdigest(['77777', '1', '99999'].join)

        success_params.merge!({
          'subscriptionId' => '77777',
          'dynamicPricingValidationDigest' => correct_digest
        })

        postback = CCBill::Postback.new(success_params)
        expect(postback.verified?).to be_truthy
      end

      it 'returns false for incorrect digest' do
        incorrect_digest = 'some_fake_digest'

        success_params.merge!({
          'dynamicPricingValidationDigest' => incorrect_digest
        })

        postback = CCBill::Postback.new(success_params)
        expect(postback.verified?).to be_falsy
      end
    end

    context 'failure response' do
      it 'returns true for correct digest' do
        correct_digest = Digest::MD5.hexdigest(['77777', '0', '99999'].join)

        failure_params.merge!({
          'transactionId' => '77777',
          'dynamicPricingValidationDigest' => correct_digest
        })

        postback = CCBill::Postback.new(failure_params)
        expect(postback.verified?).to be_truthy
      end

      it 'returns false for incorrect digest' do
        incorrect_digest = 'some_fake_digest'

        failure_params.merge!({
          'dynamicPricingValidationDigest' => incorrect_digest
        })

        postback = CCBill::Postback.new(failure_params)
        expect(postback.verified?).to be_falsy
      end
    end
  end

  def success_params
    @success_params ||= json_data(filename: 'reccuring_new_sale_success.json')
  end

  def failure_params
    @failure_params ||= json_data(filename: 'reccuring_new_sale_failure.json')
  end

  def json_data(filename:)
    file_path = File.join('responses', filename)
    file_content = File.read(file_path)

    JSON.parse(file_content)
  end
end

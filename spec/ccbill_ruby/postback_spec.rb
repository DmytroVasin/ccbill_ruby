require 'ccbill_ruby'

describe CCBill::DynamicPricing do
  before do
    CCBill.configure do |config|
      config.salt = '99999'
    end
  end

  context '#approval?' do
    it 'return true value on correct request' do
      postback = CCBill::Postback.new(approval_params)
      expect(postback.approval?).to be_truthy
    end
  end

  context '#denial?' do
    it 'return true value on correct request' do
      postback = CCBill::Postback.new(approval_params)
      expect(postback.approval?).to be_truthy
    end
  end

  # pending: 'Does not work in test ENV ( according to support )'
  xcontext 'verified?' do
    context 'approval response' do
      it 'returns true for correct digest' do
        correct_digest = Digest::MD5.hexdigest(['77777', '1', '99999'].join)

        approval_params.merge({
          'subscription_id' => '77777',
          'responseDigest' => correct_digest
        })

        postback = CCBill::Postback.new(approval_params)
        expect(postback.verified?).to be_truthy
      end

      it 'returns false for incorrect digest' do
        incorrect_digest = 'some_fake_digest'

        approval_params.merge({
          'responseDigest' => incorrect_digest
        })

        postback = CCBill::Postback.new(approval_params)
        expect(postback.verified?).to be_falsy
      end
    end

    context 'denial response' do
      it 'returns true for correct digest' do
        correct_digest = Digest::MD5.hexdigest(['77777', '0', '99999'].join)

        denial_params.merge({
          'denialId' => '77777',
          'responseDigest' => correct_digest
        })

        postback = CCBill::Postback.new(denial_params)
        expect(postback.verified?).to be_truthy
      end

      it 'returns false for incorrect digest' do
        incorrect_digest = 'some_fake_digest'

        denial_params.merge({
          'responseDigest' => incorrect_digest
        })

        postback = CCBill::Postback.new(denial_params)
        expect(postback.verified?).to be_falsy
      end
    end
  end

  def approval_params
    {
      "referer" => "",
      "country" => "UA",
      "ccbill_referer" => "",
      "customer_fname" => "testss",
      "rebills" => "0",
      "subscription_id" => "0117230502000000023",
      "password" => "",
      "reservationId" => "",
      "formDigest" => "185ab4bd5ce1f15c8382269e1237d7a6",
      "price" => "$3.55(USD) for 30 days (non-recurring)",
      "state" => "Cherkas`ka Oblast`",
      "affiliate_system" => "",
      "recurringPeriod" => "0",
      "initialPrice" => "3.55",
      "reasonForDeclineCode" => "",
      "sku_id" => "",
      "affiliateId" => "",
      "productDesc" => " ",
      "zipcode" => "12312312",
      "reasonForDecline" => "",
      "phone_number" => "",
      "typeId" => "0001162789",
      "order_id" => "88832222",
      "paymentAccount" => "3c225b035f8fcd24b387c851e3604097",
      "allowedTypes" => "",
      "city" => "testss",
      "accountingAmount" => "3.55",
      "clientSubacc" => "0000",
      "baseCurrency" => "840",
      "referringUrl" => "none",
      "initialPeriod" => "30",
      "formName" => "003ff",
      "denialId" => "",
      "email" => "testss@gmail.com",
      "start_date" => "2017-08-18 01:46:50",
      "address1" => "testss",
      "cardType" => "VISA",
      "recurringPrice" => "0.00",
      "responseDigest" => "43cfe4d2ba127210fc8bd79dadcf90b",
      "ip_address" => "217.20.178.5",
      "avsResponse" => "",
      "cvv2Response" => "",
      "prePaid" => "",
      "customer_lname" => "testss",
      "initialFormattedPrice" => "$3.55(USD)",
      "affiliate" => "",
      "currencyCode" => "840",
      "clientAccnum" => "947687",
      "recurringFormattedPrice" => "$0.00(USD)",
      "username" => ""
    }
  end

  def denial_params
    {

    }
  end
end

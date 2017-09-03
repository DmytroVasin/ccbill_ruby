require 'ccbill_ruby'

describe CCBill::DynamicPricing do
  before do
    CCBill.configure do |config|
      config.mode = :test
      config.salt = '99999'
      config.default_currency = '840' # USD
      config.account = '111111'
      config.sub_account = '0000'
      config.flexform_id = '1234567890'
      config.min_price = '2.95'
      config.max_price = '100'
    end
  end

  describe '#valid?' do
    let(:ccbill) { CCBill::DynamicPricing.new(options) }

    context 'single billing transactions' do
      context 'is invalid' do
        context 'with empty options' do
          let(:options) { {} }

          it 'fails if missing a required field' do
            expect(ccbill.valid?).to be_falsey
          end

          it 'contains lists of errors' do
            ccbill.valid?
            expect(ccbill.errors).to_not be_empty
            expect(ccbill.errors).to include('initial_period is required.')
          end
        end

        context 'with incorrect price' do
          let(:options) {{
            initial_price_in_cents: 100,
            initial_period: 30
          }}

          it 'contains price specific error' do
            expect(ccbill.valid?).to be_falsey
            expect(ccbill.errors).to_not be_empty
            expect(ccbill.errors).to match_array([
              'Initial price must be between $2.95 and $100.'
            ])
          end
        end

        context 'with configured min/max price' do
          let(:options) {{
            initial_price_in_cents: 300,
            initial_period: 30
          }}

          before do
            CCBill.configure do |config|
              config.min_price = '10'
              config.max_price = '200'
            end
          end

          it 'display correct error' do
            expect(ccbill.valid?).to be_falsey
            expect(ccbill.errors).to_not be_empty
            expect(ccbill.errors).to match_array([
              'Initial price must be between $10 and $200.'
            ])
          end
        end
      end

      context 'is valid' do
        let(:options) {{
          initial_price_in_cents: 300,
          initial_period: 30
        }}

        it 'succeeds if all required fields included' do
          expect(ccbill.valid?).to be_truthy
        end

        it 'lists no errors' do
          ccbill.valid?
          expect(ccbill.errors).to be_empty
        end

        context 'with configured min/max price' do
          let(:options) {{
            initial_price_in_cents: 15000,
            initial_period: 30
          }}

          before do
            CCBill.configure do |config|
              config.min_price = '10'
              config.max_price = '200'
            end
          end

          it 'accept bigger amount then default' do
            expect(ccbill.valid?).to be_truthy
            expect(ccbill.errors).to be_empty
          end
        end
      end
    end

    context 'recurring transactions' do
      context 'is invalid' do
        let(:options) {{
          recurring_period: 30
        }}

        it 'fails if missing a required field' do
          expect(ccbill.valid?).to be_falsey
        end

        it 'lists errors' do
          ccbill.valid?
          expect(ccbill.errors).to_not be_empty
          expect(ccbill.errors).to match_array([
            'Initial price must be between $2.95 and $100.',
            'Recurring price must be between $2.95 and $100.',
            'initial_period is required.',
            'initial_price is required.',
            'num_rebills is required.',
            'recurring_price is required.'
          ])
        end

        context 'with incorrect price' do
          let(:options) {{
            initial_price_in_cents: 3000,
            initial_period: 30,
            recurring_price_in_cents: 100,
            recurring_period: 30,
            num_rebills: 99
          }}

          it 'contains price specific error' do
            ccbill.valid?
            expect(ccbill.errors).to_not be_empty
            expect(ccbill.errors).to match_array([
              'Recurring price must be between $2.95 and $100.'
            ])
          end
        end

        context 'with configured min/max price' do
          let(:options) {{
            initial_price_in_cents: 300,
            initial_period: 30,
            recurring_price_in_cents: 300,
            recurring_period: 30,
            num_rebills: 99
          }}

          before do
            CCBill.configure do |config|
              config.min_price = '10'
              config.max_price = '200'
            end
          end

          it 'display correct error' do
            expect(ccbill.valid?).to be_falsey
            expect(ccbill.errors).to_not be_empty
            expect(ccbill.errors).to match_array([
              'Initial price must be between $10 and $200.',
              'Recurring price must be between $10 and $200.'
            ])
          end
        end
      end

      context 'is valid' do
        let(:options) {{
          initial_price_in_cents: 300,
          initial_period: 30,
          recurring_price_in_cents: 1000,
          recurring_period: 30,
          num_rebills: 99
        }}

        it 'succeeds if all required fields included' do
          expect(ccbill.valid?).to be_truthy
        end

        it "lists no errors" do
          ccbill.valid?
          expect(ccbill.errors).to be_empty
        end

        context 'with configured min/max price' do
          let(:options) {{
            initial_price_in_cents: 10000,
            initial_period: 30,
            recurring_price_in_cents: 15000,
            recurring_period: 30,
            num_rebills: 99
          }}

          before do
            CCBill.configure do |config|
              config.min_price = '10'
              config.max_price = '200'
            end
          end

          it 'accept bigger amount then default' do
            expect(ccbill.valid?).to be_truthy
            expect(ccbill.errors).to be_empty
          end
        end
      end
    end
  end

  describe '#convert_to_price' do
    context 'converts cents to ccbill price' do
      it 'price 1' do
        ccbill = CCBill::DynamicPricing.new({
          initial_price_in_cents: 321,
          initial_period: 30
        })
        expect(ccbill.variables[:initial_price]).to eq('3.21')
      end

      it 'price 2' do
        ccbill = CCBill::DynamicPricing.new({
          initial_price_in_cents: 300,
          initial_period: 30
        })
        expect(ccbill.variables[:initial_price]).to eq('3.00')
      end
    end
  end

  describe '#encode_form_digest' do
    context 'single billing transactions' do
      it 'returns hexdigest of the proper fields' do
        ccbill = CCBill::DynamicPricing.new({
          initial_price_in_cents: 9021,
          initial_period: 30
        })
        string_value = ['90.21', '30', '840', '99999'].join
        expect(ccbill.send(:encode_form_digest)).to eq(Digest::MD5.hexdigest(string_value))
      end
    end

    context 'recurring transactions' do
      it 'returns hexdigest of the proper fields' do
        ccbill = CCBill::DynamicPricing.new({
          initial_price_in_cents: 9021,
          initial_period: 30,
          recurring_price_in_cents: 300,
          recurring_period: 10,
          num_rebills: 99
        })
        string_value = ['90.21', '30', '3.00', '10', '99', '840', '99999'].join
        expect(ccbill.send(:encode_form_digest)).to eq(Digest::MD5.hexdigest(string_value))
      end
    end
  end

  describe '#url' do
    it 'raise when missing fields' do
      ccbill = CCBill::DynamicPricing.new()
      expect { ccbill.url }.to raise_error(CCBill::DynamicPricingError)
    end

    context 'combined url' do
      let(:ccbill) do
        CCBill::DynamicPricing.new({
          initial_price_in_cents: 300,
          initial_period: 30
        })
      end

      it 'points to the sandbox by default' do
        host  = 'https://sandbox-api.ccbill.com/wap-frontflex/flexforms'
        path  = CCBill.configuration.flexform_id
        digest_string = Digest::MD5.hexdigest(['3.00', '30', '840', '99999'].join)
        query = <<-QUERY.gsub(/\s+/, '').strip
          clientAccnum=111111&
          clientSubacc=0000&
          currencyCode=840&
          initialPeriod=30&
          initialPrice=3.00&
          formDigest=#{digest_string}
        QUERY

        expect(ccbill.url).to eq("#{host}/#{path}?#{query}")
      end
    end

    context 'test mode' do
      let(:ccbill) do
        CCBill::DynamicPricing.new({
          initial_price_in_cents: 300,
          initial_period: 30
        })
      end

      it 'points to the sandbox by default' do
        expect(ccbill.url).to include('https://sandbox-api.ccbill.com')
      end
    end

    context 'live mode' do
      before do
        CCBill.configure do |config|
          config.mode = :live
        end
      end

      it 'points to the live server' do
        ccbill = CCBill::DynamicPricing.new({
          initial_price_in_cents: 300,
          initial_period: 30
        })

        expect(ccbill.url).to include('https://api.ccbill.com')
      end
    end
  end

  describe '#fail_on_price_set' do
    it 'fails when user sets initial_price or recurring_price mannually' do
      expect {
        CCBill::DynamicPricing.new({
          initial_price:    30,
          initial_period:   30,
          recurring_price:  30,
          recurring_period: 30,
          num_rebills:      99
        })
      }.to raise_error(SyntaxError, "You misspelled! Gem uses initial_price_in_cents, recurring_price_in_cents value(s).")
    end
  end
end

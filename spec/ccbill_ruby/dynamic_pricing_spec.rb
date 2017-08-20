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
    end
  end

  describe '#valid?' do
    let(:ccbill) { CCBill::DynamicPricing.new(options) }

    context 'single billing transactions' do
      context 'is invalid' do
        context "with empty options" do
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
            initial_price: 1.00,
            initial_period: 30
          }}

          it 'contains price specific error' do
            ccbill.valid?
            expect(ccbill.errors).to_not be_empty
            expect(ccbill.errors).to match_array([
              'Price must be between $2.95 and $100.'
            ])
          end
        end
      end

      context 'is valid' do
        let(:options) {{
          initial_price: 3.00,
          initial_period: 30
        }}

        it 'succeeds if all required fields included' do
          expect(ccbill.valid?).to be_truthy
        end

        it 'lists no errors' do
          ccbill.valid?
          expect(ccbill.errors).to be_empty
        end
      end
    end

    context "recurring transactions" do
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
            'Price must be between $2.95 and $100.',
            'initial_period is required.',
            'initial_price is required.',
            'rebills is required.',
            'recurring_price is required.'
          ])
        end
      end

      context 'is valid' do
        let(:options) {{
          initial_price: 3.00,
          initial_period: 30,
          recurring_price: 10.00,
          recurring_period: 30,
          rebills: 99
        }}

        it 'succeeds if all required fields included' do
          expect(ccbill.valid?).to be_truthy
        end

        it "lists no errors" do
          ccbill.valid?
          expect(ccbill.errors).to be_empty
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
          initial_price: 90.21,
          initial_period: 30
        })
        string_value = ['90.21', '30', '840', '99999'].join
        expect(ccbill.send(:encode_form_digest)).to eq(Digest::MD5.hexdigest(string_value))
      end
    end

    context 'recurring transactions' do
      it 'returns hexdigest of the proper fields' do
        ccbill = CCBill::DynamicPricing.new({
          initial_price: 90.21,
          initial_period: 30,
          recurring_price: 1,
          recurring_period: 10,
          rebills: 99
        })
        string_value = ['90.21', '30', '1', '10', '99', '840', '99999'].join
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
          initial_price: 3.00,
          initial_period: 30
        })
      end

      it 'points to the sandbox by default' do
        host  = 'https://sandbox-api.ccbill.com/wap-frontflex/flexforms'
        path  = CCBill.configuration.flexform_id
        query = <<-QUERY.gsub(/\s+/, '').strip
          clientAccnum=111111&
          clientSubacc=0000&
          currencyCode=840&
          initialPrice=3.0&
          initialPeriod=30&
          formDigest=673e3c8a29af60a09f933e15bf86e5e1
        QUERY

        expect(ccbill.url).to eq("#{host}/#{path}?#{query}")
      end
    end

    context 'test mode' do
      let(:ccbill) do
        CCBill::DynamicPricing.new({
          initial_price: 3.00,
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
end

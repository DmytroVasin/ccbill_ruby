module CCBill
  class DynamicPricingError < StandardError; end

  class DynamicPricing
    attr_accessor :variables, :config, :errors

    def initialize(options = {})
      modified_options = modify_params(options)

      self.config = CCBill.configuration
      self.variables = {
        account:        config.account,
        sub_account:    config.sub_account,
        currency_code:  config.default_currency
      }.merge(modified_options)
    end

    def url
      raise DynamicPricingError.new(errors.join(' ')) if !valid?

      variables[:form_digest] = encode_form_digest

      config.endpoint + config.flexform_id + '?' + URI.encode_www_form(transformed_variables)
    end

    def valid?
      @errors = []

      required_fields.each do |field|
        @errors << "#{field} is required." if !variables[field]
      end

      unless (2.96..99.99).include?(variables[:initial_price].to_f)
        @errors << 'Price must be between $2.95 and $100.'
      end

      @errors.empty?
    end

    private

    def encode_form_digest
      hashed_fields = if recurring?
        [
          variables[:initial_price],
          variables[:initial_period],
          variables[:recurring_price],
          variables[:recurring_period],
          variables[:rebills],
          variables[:currency_code],
          config.salt
        ]
      else
        [
          variables[:initial_price],
          variables[:initial_period],
          variables[:currency_code],
          config.salt
        ]
      end

      Digest::MD5.hexdigest(hashed_fields.join)
    end

    def recurring?
      variables[:recurring_price] || variables[:recurring_period] || variables[:rebills]
    end

    def required_fields
      req = [
        :initial_price,
        :initial_period
      ]

      if recurring?
        req += [
          :recurring_price,
          :recurring_period,
          :rebills
        ]
      end

      req
    end

    def ccbill_field(internal)
      {
        account:          'clientAccnum',
        sub_account:      'clientSubacc',
        initial_price:    'initialPrice',
        initial_period:   'initialPeriod',
        currency_code:    'currencyCode',
        recurring_price:  'recurringPrice',
        recurring_period: 'recurringPeriod',
        rebills:          'numRebills',
        form_digest:      'formDigest'
      }[internal] || internal
    end

    def transformed_variables
      transform_keys(variables) { |key| ccbill_field(key) }
    end

    # From Active Support:
    def transform_keys(_hash)
      result = {}
      _hash.keys.each do |key|
        result[yield(key)] = _hash[key]
      end
      result
    end


    def modify_params(options)
      initial_cents = options.delete(:initial_price_in_cents)
      options[:initial_price] = convert_to_price(initial_cents) if initial_cents

      options
    end

    def convert_to_price(cents)
      '%.2f' % (cents / 100.to_f)
    end
  end
end

describe AdvertisingHelper do

  describe AdvertisingHelper::AdvertisingFormatterHelper do
    describe '.format_ad_setTargeting' do
      subject { AdvertisingHelper::AdvertisingFormatterHelper }
      context 'when the parameter is an array' do
        it 'should return the parameter' do
          parameter = ['param1', 'param2']
          value = subject.format_ad_setTargeting(parameter)
          expect(value).to be_an_instance_of Array
          expect(value).to eql parameter
        end
      end

      [:class, 'class', Class, 9910897115115, 9910897115115.0].each do | parameter |
        context "when the parameter is a #{parameter.class}" do

          it 'should return a string' do
            value = subject.format_ad_setTargeting(parameter)
            expect(value).to be_an_instance_of String
          end

          it 'should remove spaces' do
            value = subject.format_ad_setTargeting(parameter)
            expect(value).not_to include ' '
          end

          it 'should truncate it to at most 0 characters' do
            value = subject.format_ad_setTargeting(parameter)
            expect(value.length < 11).to be_truthy
          end
        end
      end
    end

  end


end

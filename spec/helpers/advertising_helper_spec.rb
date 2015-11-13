describe AdvertisingHelper do

  describe AdvertisingHelper::AdvertisingFormatterHelper do
    describe '.format_ad_setTargeting' do
      subject { AdvertisingHelper::AdvertisingFormatterHelper }
      context 'when the parameter is an array' do
        it 'should return an array' do
          parameter = ['param1', 'param2']
          value = subject.format_ad_setTargeting(parameter)
          expect(value).to be_an_instance_of Array
        end

        it 'should return an array with elements of length less than or equal to 10' do
          parameter = ['totally_more_than_ten_characters', 'yup_also_more_than_ten_characters']
          value = subject.format_ad_setTargeting(parameter)
          expect(value).to be_an_instance_of Array
          value.each do | val |
            expect(val.length <= 10).to be_truthy
          end
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

          it 'should truncate it to at most 10 characters' do
            value = subject.format_ad_setTargeting(parameter)
            expect(value.length < 11).to be_truthy
          end
        end
      end
    end

  end


end

require 'spec_helper'

describe BarCharts::TestScoresBarChart, type: 'model' do

  describe '#test_scores_bar_chart' do
    subject do
      BarCharts::TestScoresBarChart.new(testscoredata).bar_chart_array
    end

    context 'When test score graph is created' do
      let(:testscoredata) do
        {
          2013 => {
            'score' => 60,
            'school_number_tested' => 123,
            'state_avg' =>  77
          },
          2012 => {
            'score' =>  81,
            'school_number_tested' =>  145,
            'state_avg' =>  79
          },
          2011 => {
            'score' =>  63,
            'school_number_tested' =>  120,
            'state_avg' =>  65
          }
        }
      end
      # [["2013", 60, "60%", "<table style=\"line-height:1.2\" cellpadding=5><tr><td valign=\"top\"><b>123</b></td><td>Students tested</td></tr><tr><td valign=\"top\"><b>60%</b></td><td>Students are proficient or better</td></tr><tr><td valign=\"top\"><b>77%</b></td><td>State average</td></tr></table>"], ["2012", 81, "81%", "<table style=\"line-height:1.2\" cellpadding=5><tr><td valign=\"top\"><b>145</b></td><td>Students tested</td></tr><tr><td valign=\"top\"><b>81%</b></td><td>Students are proficient or better</td></tr><tr><td valign=\"top\"><b>79%</b></td><td>State average</td></tr></table>"], ["2011", 63, "63%", "<table style=\"line-height:1.2\" cellpadding=5><tr><td valign=\"top\"><b>120</b></td><td>Students tested</td></tr><tr><td valign=\"top\"><b>63%</b></td><td>Students are proficient or better</td></tr><tr><td valign=\"top\"><b>65%</b></td><td>State average</td></tr></table>"]]
      it 'it should return the year' do
        expect(subject[0][0]).to eq '2013'
      end

      it 'it should return the score' do
        expect(subject[0][1]).to eq 60
      end

      it 'it should return the display value' do
        expect(subject[0][2]).to eq '60%'
      end

      it 'it should return the tooltip' do
        expect(subject[0][3]).to eq '<table style="line-height:1.2" cellpadding=5><tr><td valign="top"><b>123</b></td><td>Students tested</td></tr><tr><td valign="top"><b>60%</b></td><td>Students are proficient or better</td></tr><tr><td valign="top"><b>77%</b></td><td>State average</td></tr></table>'
      end
    end
  end

  #  needs to be refined once actual proficiency and advanced scores are available
  describe BarCharts::TestScoresBarChartStacked, type: 'model' do

    describe '#test_scores_bar_chart' do
      subject do
        BarCharts::TestScoresBarChartStacked.new(testscoredata).bar_chart_array
      end

      context 'When test score graph is created' do
        let(:testscoredata) do
          {
            2013 => {
              'score' => 60,
              'school_number_tested' => 123,
              'state_avg' =>  77,
              'proficient_score' => 61,
              'proficient_school_number_tested' => 124,
              'proficient_state_avg' => 78,
              'advanced_score' => 1,
              'advanced_school_number_tested' => 1,
              'advanced_state_avg' => 1
            },
            2012 => {
              'score' =>  81,
              'school_number_tested' =>  145,
              'state_avg' =>  79
            },
            2011 => {
              'score' =>  63,
              'school_number_tested' =>  120,
              'state_avg' =>  65
            }
          }
        end

        it 'it should return the year' do
          expect(subject[0][0]).to eq '2013'
        end

        it 'it should return the score' do
          expect(subject[0][1]).to eq 61
        end

        it 'it should return the display value' do
          expect(subject[0][2]).to eq '61%'
        end

        it 'it should return the tooltip' do
          expect(subject[0][3]).to eq '<table style="line-height:1.2" cellpadding=5><tr><td valign="top"><b>123</b></td><td>Students tested</td></tr><tr><td valign="top"><b>60%</b></td><td>Students are proficient or better</td></tr><tr><td valign="top"><b>77%</b></td><td>State average</td></tr></table>'
        end
      end
    end
  end
end
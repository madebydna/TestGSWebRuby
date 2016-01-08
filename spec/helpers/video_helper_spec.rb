require 'spec_helper'

describe VideoHelper do

  describe '#youtube_parse_id_from_str' do
    it 'should parse id from long url without parameters' do
      youtube_id = youtube_parse_id_from_str('https://www.youtube.com/watch?v=FxdvM7epMUA')
      expect(youtube_id).to eq('FxdvM7epMUA')
    end

    it 'should parse id from long url with parameters' do
      youtube_id = youtube_parse_id_from_str('https://www.youtube.com/watch?v=FxdvM7epMUA&maru=kawaii?hana=kawaii')
      expect(youtube_id).to eq('FxdvM7epMUA')
    end

    it 'should parse id from short url without parameters' do
      youtube_id = youtube_parse_id_from_str('https://youtu.be/FxdvM7epMUA')
      expect(youtube_id).to eq('FxdvM7epMUA')
    end

    it 'should parse id from short url with parameters' do
      youtube_id = youtube_parse_id_from_str('https://youtu.be/FxdvM7epMUA?maru=kawaii&hana=kawaii')
      expect(youtube_id).to eq('FxdvM7epMUA')
    end
  end

  # TODO: move media gallery to front end to show vimeo. Cannot do vimeo API calls from the server right now.
  # describe '#vimeo_parse_id_from_str' do
  #   it 'should parse vimeo id from long url' do
  #     vimeo_id = vimeo_parse_id_from_str('https://vimeo.com/channels/staffpicks/129710408')
  #     expect(vimeo_id).to eq('129710408')
  #   end
  #
  #   it 'should parse vimeo id from short url' do
  #     vimeo_id = vimeo_parse_id_from_str('https://vimeo.com/129710408')
  #     expect(vimeo_id).to eq('129710408')
  #   end
  # end
  #
  # describe '#create_vimeo_api_url' do
  #   it 'should insert vimeo video id into api url' do
  #     vimeo_id = '129710408'
  #     expect(create_vimeo_api_url(vimeo_id)).to eq('https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/129710408')
  #   end
  # end
  #
  # describe '#vimeo_lightbox_thumbnail' do
  #   it 'should retrieve vimeo thumbnail from api' do
  #     config = {'thumbnail_url' => 'www.correctthumbnail.com'}.to_json
  #     parsed_json = JSON.parse(config)
  #     expect(parsed_json['thumbnail_url']).to eq('www.correctthumbnail.com')
  #   end
  # end

end

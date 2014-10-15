module MapIconConcerns

  icon_path = 'app/assets/images/pyoc/map_icons/'

  Zipcode_to_icon_mapping = {
      '53110' => icon_path + 'Mke_map_6.png',
      '53129' => icon_path + 'Mke_map_5.png',
      '53130' => icon_path + 'Mke_map_5.png',
      '53202' => icon_path + 'Mke_map_4.png',
      '53203' => icon_path + 'Mke_map_4.png',
      '53204' => icon_path + 'Mke_map_6.png',
      '53205' => icon_path + 'Mke_map_4.png',
      '53206' => icon_path + 'Mke_map_4.png',
      '53207' => icon_path + 'Mke_map_6.png',
      '53208' => icon_path + 'Mke_map_3.png',
      '53209' => icon_path + 'Mke_map_2.png',
      '53210' => icon_path + 'Mke_map_3.png',
      '53211' => icon_path + 'Mke_map_4.png',
      '53212' => icon_path + 'Mke_map_4.png',
      '53213' => icon_path + 'Mke_map_3.png',
      '53214' => icon_path + 'Mke_map_5.png',
      '53215' => icon_path + 'Mke_map_6.png',
      '53216' => icon_path + 'Mke_map_3.png',
      '53217' => icon_path + 'Mke_map_2.png',
      '53218' => icon_path + 'Mke_map_1.png',
      '53219' => icon_path + 'Mke_map_5.png',
      '53220' => icon_path + 'Mke_map_5.png',
      '53221' => icon_path + 'Mke_map_6.png',
      '53222' => icon_path + 'Mke_map_3.png',
      '53223' => icon_path + 'Mke_map_1.png',
      '53224' => icon_path + 'Mke_map_1.png',
      '53225' => icon_path + 'Mke_map_1.png',
      '53226' => icon_path + 'Mke_map_3.png',
      '53227' => icon_path + 'Mke_map_5.png',
      '53228' => icon_path + 'Mke_map_5.png',
      '53233' => icon_path + 'Mke_map_4.png',
      '53235' => icon_path + 'Mke_map_6.png',
  }

  def which_icon
    Zipcode_to_icon_mapping[zipcode].present? ? map_icon = Zipcode_to_icon_mapping[zipcode] : map_icon ='N/A'
  end
end
module WebpackAssets 
  def self.lookup(name)
    self.asset_map[name]
  end

  def self.asset_map
    return @_asset_map if @_asset_map

    images_base_path = 'app/assets/images/'

    image_assets = asset_manifest['assets'].select do |asset, _|
      # Only include image assets in the lookup hash.
      asset.include?(images_base_path)
    end 

    translated = image_assets.each_with_object({}) do |(asset, fingerprinted_asset), hash|
      # Trim to ensure path matching is correct --
      # if image is at `app/assets/images/path/to/image.png`, 
      # we want to use `image_tag('path/to/image.png') as expected.
      asset_tail = asset.split(images_base_path).last
      hash[asset_tail] = fingerprinted_asset
    end

    @_asset_map = translated unless Rails.env.development?

    return translated
  end

  def self.asset_manifest
    manifest_filename = 'asset_map.json'

    return @_asset_manifest if @_asset_manifest
    @_asset_manifest = JSON.parse(
      File.read(
        Rails.root.join(
          'app/assets/webpack', # Rails.configuration.webpack.output_dir,
          manifest_filename
        )
      )
    )
  end
end

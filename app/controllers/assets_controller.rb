class AssetsController < ActionController::Base
  def show
    manifest_filename = 'asset_map.json'
    content = JSON.parse(
      File.read(
        Rails.root.join(
          'app/assets/webpack',
          manifest_filename
        )
      )
    ).fetch('chunks')

    respond_to do |format|
      format.js {
        render json: {data: content}, callback: params['callback']
      }
    end
  end
end

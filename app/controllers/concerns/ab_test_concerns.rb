module AbTestConcerns

# TODO: add unit specs for this test

  protected

  def ab_version
    request.headers["X-ABVersion"]
  end

  def add_ab_test_to_gon
    # Adding for a/b test
    #     Responsive-Test Group ID: 4517881831
    #     Control ID: 4020610234
    responsive_ads = "4517881831"
    control_id = "4020610234"

    ab_id = ''
    if(ab_version == "a")
      ab_id = control_id
    elsif (ab_version == "b")
      ab_id = responsive_ads
    end
    gon.ad_set_channel_ids = ab_id
    gon.ab_value = ab_version
  end

end

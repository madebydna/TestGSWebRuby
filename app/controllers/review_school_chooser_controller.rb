class ReviewSchoolChooserController < ApplicationController
  def show
    write_tags_and_gon
  end

  def morgan_stanley
    write_tags_and_gon
    @display_morgan_stanley = ''
  end

  def write_tags_and_gon
    @display_morgan_stanley = 'dn'
    gon.pagename = "Write a school review | GreatSchools"
    gon.omniture_pagename = 'GS:Promo:Reviews'
    set_meta_tags :title => "Write a school review | GreatSchools" , :description => "Write a review for your child's school today and you can help other parents make a
    more informed choice about which school is right for their family."
  end

end
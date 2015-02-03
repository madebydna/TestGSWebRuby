class ReviewSchoolChooserController < ApplicationController
  def show
    gon.pagename = "Write a school review | GreatSchools"
    gon.omniture_pagename = 'GS:Promo:Reviews'
    set_meta_tags :title => "Write a school review | GreatSchools" , :description => "Write a review for your child's school today and you can help other parents make a
    more informed choice about which school is right for their family."
  end

end
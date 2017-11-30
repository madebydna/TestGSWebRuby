require File.expand_path('../../config/environment', __FILE__)

esp_memberships = EspMembership.where(status: 'approved', active: true)

esp_memberships.select { |em| em.school_id.present? }.each { |em| SchoolUser.make_from_esp_membership(em) }

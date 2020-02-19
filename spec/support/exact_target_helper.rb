module ExactTargetHelper
  def invalid_credentials_auth_body
    "{\"error\":\"invalid_client\",\"error_description\":\"Invalid client ID. Use the client ID in Marketing Cloud Installed Packages.\",\"error_uri\":\"https://developer.salesforce.com/docs\"}"
  end

  def valid_credentials_auth_body
    "{\"access_token\":\"1k7HGfBRUDHXXWvXySpKW5eS\",\"expires_in\":3599}"
  end

  def valid_auth_token_body
    "{\"count\":\"1\",\"createDate\":\"2016-05-04T20:17:16.5143576Z\",\"completeDate\":\"2016-05-04T20:17:16.8261776Z\",\"contacts\":[{\"mobileNumber\":\"15103015114\",\"shortCode\":\"88769\",\"keyword\":\"WORDS\",\"optInDate\":\"2016-03-30T11:51:44.9270000\",\"status\":\"active\"}]}"
  end

  def invalid_auth_token_response_body
    "{\"documentation\":\"https://code.docs.exacttarget.com/rest/errors/403\",\"errorcode\":0,\"message\":\"Not Authorized\"}"
  end
end
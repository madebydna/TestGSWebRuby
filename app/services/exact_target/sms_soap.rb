require 'fuelsdk'

class ExactTarget
  class SmsSoap


    def exacttarget_login
      FuelSDK::Client.new (
                              {
                                  'client' => {
                                      'id' => ENV_GLOBAL['exacttarget_v2_api_key'],
                                      'secret' => ENV_GLOBAL['exacttarget_v2_api_secret']
                                  }
                              }
                          )
    end

    # SET DATA EXTENSION ROW
    # my_client = FuelSDK::Client.new {'client' => { 'id' => CLIENTID, 'secret' => SECRET }}
    # dataextensionrow = FuelSDK::DataExtension::Row.new
    # dataextensionrow.authStub = my_client
    # dataextensionrow.Name = 'ExampleDEName'
    # dataextensionrow.props = {"Name" => "ExampleNameValue", "OtherField" => "Some randon text for the other field"}
    # results = dataextensionrow.post
    # p results

    # GET DATA EXTENSION ROW
    def get_data_extension_row_status
      my_client = exacttarget_login
      dataextensionrow = FuelSDK::DataExtension::Row.new
      dataextensionrow.authStub = my_client
      dataextensionrow.name = '_MobileSubscription'
      dataextensionrow.props = ['_OptInStatusID', '_MobileNumber', '_OptInDate']
      # dataextensionrow.props = ["phone" => 14421544554, "email" => "mseltzer@greatschools.org", 'subscriber_id'=> 12]
      # @response = dataextensionrow.post
      # dataextensionrow.filter = {'Property' => 'name', 'SimpleOperator' => 'equals', 'Value' => 'Mobile Test'}
      # @response = dataextensionrow.get
      # p response
      #
      # dataextension = FuelSDK::DataExtension::Row.new
      # dataextension.authStub = my_client
      # dataextension.Name = 'Mobile Test'
      require 'pry'
      binding.pry
      @response = dataextensionrow.get
    end


    # GET DATA EXTENSION ROW
    def get_data_extension_row_mobile_test
      my_client = exacttarget_login
      dataextensionrow = FuelSDK::DataExtension::Row.new
      dataextensionrow.authStub = my_client
      dataextensionrow.name = 'Mobile Test'
      dataextensionrow.props = ['phone', 'messaging_join_date', 'email']
      # dataextensionrow.props = ["phone" => 14421544554, "email" => "mseltzer@greatschools.org", 'subscriber_id'=> 12]
      # @response = dataextensionrow.post
      # dataextensionrow.filter = {'Property' => 'name', 'SimpleOperator' => 'equals', 'Value' => 'Mobile Test'}
      # @response = dataextensionrow.get
      # p response
      #
      # dataextension = FuelSDK::DataExtension::Row.new
      # dataextension.authStub = my_client
      # dataextension.Name = 'Mobile Test'
      # require 'pry'
      # binding.pry
      @response = dataextensionrow.get
    end

    # SET DATA EXTENSION ROW
    def set_data_extension_row(person_info)
      my_client = exacttarget_login
      dataextensionrow = FuelSDK::DataExtension::Row.new
      dataextensionrow.authStub = my_client
      dataextensionrow.name = 'Mobile Test'
      # dataextensionrow.props = ['phone', 'messaging_join_date', 'email']
      p = person_info[:phone]
      e = person_info[:email]
      dataextensionrow.props = ["phone" => person_info[:phone], "email" => person_info[:email], "subscriber_id" =>
                                                                  person_info[:subscriber_id]]
      # @response = dataextensionrow.post
      # dataextensionrow.filter = {'Property' => 'name', 'SimpleOperator' => 'equals', 'Value' => 'Mobile Test'}
      # @response = dataextensionrow.get
      # p response
      #
      # dataextension = FuelSDK::DataExtension::Row.new
      # dataextension.authStub = my_client
      # dataextension.Name = 'Mobile Test'
      # require 'pry'
      # binding.pry
      dataextensionrow.post

    end

    # my_client = FuelSDK::Client.new {'client' => { 'id' => CLIENTID, 'secret' => SECRET }}
    # dataextensionrow = FuelSDK::DataExtension::Row.new
    # dataextensionrow.authStub = my_client
    # dataextensionrow.Name = 'ExampleDEName'
    # dataextensionrow.props = ['FirstName', 'LastName', 'AnotherColumnName']
    # response = dataextensionrow.get
    # p respon.props = ["Name"]
    def get_columns
      dataextensioncolumn = FuelSDK::DataExtension::Column.new
      my_client = exacttarget_login
      dataextensioncolumn.authStub = my_client
      dataextensioncolumn.props = ["Name", "CustomerKey"]
      dataextensioncolumn.filter = {'Property' => 'CustomerKey', 'SimpleOperator' => 'equals', 'Value' => '[6A8A3ED9-CFBD-4728-ADE8-B5885427CB1D].[Subscriber_key]'}
      response = dataextensioncolumn.get
      p response
    end


    # GET DATA EXTENSIONS
    def get_data_extensions
      my_client = exacttarget_login
      dataextension = FuelSDK::DataExtension.new
      dataextension.authStub = my_client
      # dataextension.Name = 'Mobile Test'
      # ObjectID
      # PartnerKey
      # CustomerKey
      # Name
      # CreatedDate
      # ModifiedDate
      # Client.ID
      # Description
      # IsSendable
      # IsTestable
      # SendableDataExtensionField.Name
      # SendableSubscriberField.Name
      # Template.CustomerKey
      # CategoryID
      # Status
      # IsPlatformObject
      # DataRetentionPeriodLength
      # DataRetentionPeriodUnitOfMeasure
      # RowBasedRetention
      # ResetRetentionPeriodOnImport
      # DeleteAtEndOfRetentionPeriod
      # RetainUntil
      # DataRetentionPeriod
      dataextension.props = ['Name', 'CustomerKey', 'CreatedDate']
      dataextension.filter = {'Property' => 'name', 'SimpleOperator' => 'equals', 'Value' => 'All Subscriptions'}

      @response = dataextension.get
      # p response
    end


    # SELECT
    # _CreatedBy AS CreatedBy,
    # _OptOutMethodID AS OptOutMethodID,
    #  _MobileNumber AS MobileNumber,
    # _OptInDate AS OptInDate,
    # _Source AS Source,
    #  _OptOutStatusID AS OptOutStatusID,
    # _OptOutDate AS OptOutDate,
    #  _ModifiedBy AS ModifiedBy,
    # _SourceObjectId AS SourceObjectId,
    #  _SubscriptionDefinitionID AS SubscriptionDefinitionID,
    # _CreatedDate AS CreatedDate,
    # _OptInStatusID AS OptInStatusID,
    # _OptInMethodID AS OptInMethodID,
    # _ModifiedDate AS ModifiedDate
    # FROM _MobileSubscription
    #
    # SELECT _CarrierID AS CarrierID,
    #  _Channel AS Channel,
    #  _City AS City,
    # _ContactID AS ContactID,
    # _CountryCode AS CountryCode,
    # _CreatedBy AS CreatedBy,
    # _CreatedDate AS CreatedDate,
    # _FirstName AS FirstName,
    # _IsHonorDST AS IsHonorDST,
    #  _LastName AS LastName,
    # _MobileNumber AS MobileNumber,
    #  _ModifiedBy AS ModifiedBy,
    # _ModifiedDate AS ModifiedDate,
    #  _Priority AS Priority,
    # _Source AS Source,
    #  _SourceObjectID AS SourceObjectID,
    # _State AS State,
    # _Status AS Status,
    #  _UTCOffset AS UTCOffset,
    #  _ZipCode AS ZipCode
    # FROM _MobileAddress
  end
end

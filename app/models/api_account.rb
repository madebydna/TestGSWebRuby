class ApiAccount < ActiveRecord::Base
  self.table_name = 'api_account'
  db_magic :connection => :api_rw
  default_scope {order(account_added: :desc)}
  # api_accounts includes column with name 'type', which Rails uses for single-table inheritance
  self.inheritance_column = nil
  has_one :api_config, class_name: 'ApiConfig', foreign_key: :account_id

  validates :name, :organization, :email, :website, :phone, :industry, :intended_use, presence: true
  validates :type, presence: true, allow_nil: true
  validates :email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i}
  before_save :clean_up_api_config, :ensure_type


  def save_unique_api_key
    key = generate_api_key
    counter = 0
    until ApiAccount.where(api_key: key).empty?
      if counter >= 5
        raise Exception.new("Api key generation timeout: failed to generate unique api key in #{counter} attempts.")
      end
      key = generate_api_key
      counter += 1
    end
    self.update(api_key: key, account_updated: Time.now, key_generated: Time.now)
  end

  def generate_api_key
    seed = rand(999999999).to_s
    Digest::MD5.hexdigest(seed).gsub(/[+=]/, '+' => 'x', '=' => 'x')
  end

  def delete_api_config
    ApiConfig.delete_all(account_id: self.id)
  end

  def clean_up_api_config
    if self.type == 'f'
      delete_api_config
    end
  end

  def ensure_type
    self.type = 'f' if self.type.nil?
  end


end


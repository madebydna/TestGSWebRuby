class ApiAccount < ActiveRecord::Base
  self.table_name = 'api_account'
  db_magic :connection => :api_rw
  default_scope {order(account_added: :desc)}
  # api_accounts includes column with name 'type', which Rails uses for single-table inheritance
  self.inheritance_column = nil

  validates :name, :organization, :email, :website, :phone, :industry, :intended_use, :type, presence: true
  validates :email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i}

  def save_unique_api_key
    key = generate_api_key
    until ApiAccount.where('api_key != ? and api_key != ?', nil, key).empty?
      key = generate_api_key
    end
    self.update(api_key: key)
  end

  def generate_api_key
    seed = rand(999999999).to_s
    Digest::MD5.hexdigest(seed).gsub(/[+=]/, '+' => 'x', '=' => 'x')
  end
end

# TODO: create admin_tools_layout.html.erb for this, osp, etc.
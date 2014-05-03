class Building < ActiveRecord::Base
  validates :address, presence: true
  validates :zip, presence: true
  validate :verify_unique_address, on: :create
  # geocoded_by :full_address
  # after_validation :geocode, :if => :address_changed?  
  after_rollback :update_duplicate_flag
  # default_scope {where full_address: true}
  scope :needs_geocoding, -> {where(geo_checked: false)}

  def update_duplicate_flag
    building = Building.find_by_address(address, zip)
    if building
      building.update_attribute(:has_duplicate, true)
    end
  end

  def verify_unique_address 
    if Building.exists?({address: address, zip: zip})
      errors.add(:address, "duplicate address")
      false
    end
  end

  def self.to_csv(options = {})
    CSV.generate do |csv|
      headers = ["id", "address", "city", "state", "zip"]
      csv << headers
      all.each do |building|
        csv << building.attributes.values_at(*headers)
      end
    end
  end

  def full_address
    "#{self.address} #{self.borough} #{self.city}, #{self.state} #{self.zip}" 
  end

  def self.find_by_address(address, zip)
    Building.where(address: address, zip: zip).first
  end

end

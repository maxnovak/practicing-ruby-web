class User < ActiveRecord::Base
  has_many :comments

  validates_presence_of   :contact_email, :on => :update
  validates_uniqueness_of :contact_email, :on => :update, :allow_blank => true

  attr_protected :admin, :status

  scope :to_notify, where(notifications_enabled: true,
    :status => %w{active payment_pending confirmed})

  before_save do
    write_attribute(:email, email.downcase) if changed.include?("email")
  end

  def active?
    %w{active payment_pending}.include? status
  end

  def disabled?
    status == 'disabled'
  end

  def name
    "#{first_name} #{last_name}"
  end

  def disable
    self.notifications_enabled = false
    self.status                = 'disabled'

    save
  end

  def enable(mailchimp_web_id=nil)
    self.notifications_enabled = true
    self.mailchimp_web_id      = mailchimp_web_id unless mailchimp_web_id.blank?
    self.status                = 'active'

    save
  end

  def enable_notifications
    unless disabled? || notifications_enabled
      update_attributes(:notifications_enabled => true)
    end
  end

  def create_access_token
    update_attribute(:access_token, SecureRandom.hex(10))
    access_token
  end

  def clear_access_token
    update_attribute(:access_token, nil)
  end
end

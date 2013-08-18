class Conversation < ActiveRecord::Base

  has_many :messages, :order => "created_at DESC"
  belongs_to :starter_user, :class_name => "User"
  belongs_to :with_user, :class_name => "User"
  validates_presence_of :starter_user_id, :with_user_id

  validate :unique_conversation

  accepts_nested_attributes_for :messages

  def self.user_scoped(user)
    where("starter_user_id = ? or with_user_id = ?", user.id, user.id)
  end

  def target_for(user)
    if self.starter_user_id == user.id
      with_user
    else
      starter_user
    end
  end

  def read!(user)
    self.messages.where(:receiver_id => user.id).update_all(:read_at => Time.now)
  end

  def has_unread_messages?(user)
    !self.messages.unread.where(:receiver_id => user.id).blank?
  end

  def has_active_message?(user)
    !self.messages.where("(sender_id = ? AND sender_deleted_at IS NULL) OR (receiver_id = ? AND receiver_deleted_at IS NULL)", user.id, user.id).blank?
  end

  private

  def unique_conversation
    errors.add(:base, "There is already active conversation") if self.starter_user.has_active_conversation_with?(self.with_user_id)
  end

end
